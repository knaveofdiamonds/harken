require 'treetop'
require 'polyglot'
require 'message'
require 'node_modules'
require 'test/unit'

include Harken

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

  def test_variable_names_can_be_captured
    context = []
    result = @parser.parse("<greeting> <person>").interpret(context)
    assert_equal [:greeting, :person], context
  end

  # This is kind of arbitrary, but it is important to know how variable values
  # will be captured
  def test_variable_captures
    result = @parser.parse("<a> <b>").interpret
    assert_equal "foo", result.match("foo bar baz")[1]
    assert_equal "bar baz", result.match("foo bar baz")[2]
  end

  def test_optional_identifiers_do_not_displace_capture_order
    result = @parser.parse("[<a>] <b>").interpret
    assert_equal nil, result.match("foo")[1]
    assert_equal "foo", result.match("foo")[2]
    assert_equal "foo", result.match("foo bar baz")[1]
    assert_equal "bar baz", result.match("foo bar baz")[2]
  end

  # pretend that "hello [world]" was really written "hello[ world]".
  def test_whitespace_can_be_implicitly_ignored
    result = @parser.parse("hello [world]").interpret
    assert result.match("hello")
    assert result.match("hello world")
    assert ! result.match("helloworld")
  end

  # pretend that "[hello] world" was really written "[hello ]world".
  def test_whitespace_can_be_ignored_after_optional
    result = @parser.parse("[hello] world").interpret
    assert result.match("hello world")
    assert result.match("world")
  end

  # Note that the following assetion would not work because of the double nesting 
  # i.e. [[...] [...]] - [...] [...] would be fine.
  # assert_equal "bar", result.match("foo with bar of baz")[2]
  def test_complicated_expression
    result = @parser.parse("[<example>] with <id> [[lots] [of [<nesting>]]]").interpret
    assert_equal "foo", result.match("foo with bar")[1]
    assert_equal "bar", result.match("foo with bar")[2]
    assert_equal "bar", result.match("foo with bar lots of")[2]
    assert_equal "bar lots", result.match("foo with bar lots lots")[2]
    assert_equal "wibble", result.match("foo with bar lots lots of wibble")[3]
    assert_equal "foo", result.match("with foo")[2]
  end

  def test_back_to_back_optionals
    result = @parser.parse("a [b] [c]").interpret
    assert result.match("a")
    assert result.match("a b")
    assert result.match("a c")
    assert result.match("a b c")
    assert ! result.match("ab")
    assert ! result.match("ac")
  end

  def test_malformed_messages
    result = @parser.parse("a [c")
    assert ! result

    result = @parser.parse("a <c")
    assert ! result
  end
end
