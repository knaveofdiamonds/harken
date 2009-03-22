require File.dirname(__FILE__) + '/helper'

class TestMessageParser < Test::Unit::TestCase
  def setup
    @parser = Harken::MessageParser.new
  end

  def test_string
    result = @parser.interpret("Hello, world!")
    assert result.match("Hello, world!")
    assert ! result.match("foo")
  end

  def test_identifier
    result = @parser.interpret("<id>")
    assert_equal "whatever blah", result.match("whatever blah").id
  end

  def test_optional
    result = @parser.interpret("[name]")
    assert result.match("")
    assert result.match("name")
    assert ! result.match("n")
  end

  def test_composite_expression
    result = @parser.interpret("fox[trot<dance>]")
    assert result.match("fox")
    assert_equal "bar", result.match("foxtrotbar").dance
    assert ! result.match("foxtrot")
  end

  def test_strings_are_regexp_escaped
    result = @parser.interpret("dr. foo")
    assert result.match("dr. foo")
    assert ! result.match("drx foo")
  end

  def test_variable_names_can_be_captured
    result = @parser.interpret("<greeting> <person>")
    assert_equal [:greeting, :person], result.variables
  end

  # This is kind of arbitrary, but it is important to know how variable values
  # will be captured
  def test_variable_captures
    result = @parser.interpret("<a> <b>")
    assert_equal "foo", result.match("foo bar baz").a
    assert_equal "bar baz", result.match("foo bar baz").b
  end

  def test_optional_identifiers_do_not_displace_capture_order
    result = @parser.interpret("[<a>] <b>")
    assert_equal nil, result.match("foo").a
    assert_equal "foo", result.match("foo").b
    assert_equal "foo", result.match("foo bar baz").a
    assert_equal "bar baz", result.match("foo bar baz").b
  end

  # pretend that "hello [world]" was really written "hello[ world]".
  def test_whitespace_can_be_implicitly_ignored
    result = @parser.interpret("hello [world]")
    assert result.match("hello")
    assert result.match("hello world")
    assert ! result.match("helloworld")
  end

  # pretend that "[hello] world" was really written "[hello ]world".
  def test_whitespace_can_be_ignored_after_optional
    result = @parser.interpret("[hello] world")
    assert result.match("hello world")
    assert result.match("world")
  end

  # Note that the following assetion would not work because of the double nesting 
  # i.e. [[...] [...]] - [...] [...] would be fine.
  # assert_equal "bar", result.match("foo with bar of baz")[2]
  def test_complicated_expression
    result = @parser.interpret("[<example>] with <id> [[lots] [of [<nesting>]]]")
    assert_equal "foo", result.match("foo with bar").example
    assert_equal "bar", result.match("foo with bar").id
    assert_equal "bar", result.match("foo with bar lots of").id
    assert_equal "bar lots", result.match("foo with bar lots lots").id
    assert_equal "wibble", result.match("foo with bar lots lots of wibble").nesting
    assert_equal "foo", result.match("with foo").id
  end

  def test_back_to_back_optionals
    result = @parser.interpret("a [b] [c]")
    assert result.match("a")
    assert result.match("a b")
    assert result.match("a c")
    assert result.match("a b c")
    assert ! result.match("ab")
    assert ! result.match("ac")
  end

  def test_malformed_messages
    result = @parser.interpret("a [c")
    assert ! result

    result = @parser.interpret("a <c")
    assert ! result
  end
end
