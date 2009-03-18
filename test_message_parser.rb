require 'treetop'
require 'polyglot'
require 'message'
require 'node_modules'
require 'test/unit'

class TestMessageParser < Test::Unit::TestCase
  def setup
    @parser = MessageParser.new
  end

  def test_string
    result = @parser.parse("Hello, world!").interpret
    assert result.match("Hello, world!")
    assert ! result.match("foo")
  end

  def test_identifier
    result = @parser.parse("<id>").interpret
    assert_equal "whatever blah", result.match("whatever blah")[1]
  end

  def test_optional
    result = @parser.parse("[name]").interpret
    assert result.match("")
    assert result.match("name")
    assert ! result.match("n")
  end

  def test_composite_expression
    result = @parser.parse("fox[trot<dance>]").interpret
    assert result.match("fox")
    assert_equal "bar", result.match("foxtrotbar")[1]
    assert ! result.match("foxtrot")
  end

  def test_strings_are_regexp_escaped
    result = @parser.parse("dr. foo").interpret
    assert result.match("dr. foo")
    assert ! result.match("drx foo")
  end

  def test_variables_can_be_captured
    context = []
    result = @parser.parse("<greeting> <person>").interpret(context)
    assert_equal [:greeting, :person], context
  end

  # pretend that "hello [world]" was really written "hello[ world]".
  def test_whitespace_can_be_implicitly_ignored
    result = @parser.parse("hello [world]").interpret
    assert result.match("hello")
    assert result.match("hello world")
    assert ! result.match("helloworld")
  end

  def test_complicated_expression
    result = @parser.parse("[<example>] with <id> [[lots] [of [<nesting>]]]").interpret
    assert_equal "foo", result.match("foo with bar")[1]
    assert_equal "bar", result.match("foo with bar")[2]
    assert_equal "bar", result.match("foo with bar lots of")[2]
    # TODO this does not work because of the double nesting i.e. [[...] [...]] - 
    # [...] [...] would be fine.
    # assert_equal "bar", result.match("foo with bar of baz")[2]
    assert_equal "bar lots", result.match("foo with bar lots lots")[2]
    assert_equal "wibble", result.match("foo with bar lots lots of wibble")[3]
    # TODO "with foo" should work as well.
    assert_equal "foo", result.match(" with foo")[2]
  end

  def test_back_to_back_optionals
    result = @parser.parse("a [b] [c]").interpret
    assert result.match("a")
    assert result.match("a b")
    assert result.match("a c")
    assert ! result.match("ab")
    assert ! result.match("ac")
  end
end
