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
    ast = @parser.parse("Hello, world!")
    assert_equal /^Hello,\ +world!$/, ast.interpret
  end

  def test_identifier
    ast = @parser.parse("<id>")
    assert_equal /^(.*)$/, ast.interpret
  end

  def test_optional
    ast = @parser.parse("[name]")
    assert_equal /^(?:name)?$/, ast.interpret
  end

  def test_composite_expression
    ast = @parser.parse("fox[[trot]<dance>]")
    assert_equal /^fox(?:(?:trot)?(.*))?$/, ast.interpret
  end

  def test_strings_are_regexp_escaped
    ast = @parser.parse("dr. foo")
    assert_equal /^dr\.\ +foo$/, ast.interpret
  end

  def test_variables_can_be_captured
    ast = @parser.parse("<greeting> <person>")
    context = []
    assert_equal /^(.*)\ +(.*)$/, ast.interpret(context)
    assert_equal [:greeting, :person], context
  end

  # We want to match "hello", not only "hello ", i.e. pretend that
  # "hello [world]" was really written "hello[ world]".
  def test_whitespace_can_be_implicitly_ignored
    ast = @parser.parse("hello [world]")
    assert_equal /^hello(?:\ +world)?$/, ast.interpret
  end

  def test_complicated_expression
    ast = @parser.parse("[<example>] with <id> [[lots] [of [<nesting>]]]")
    context = []
    assert_equal /^(?:(.*))?\ +with\ +(.*)(?:\ +(?:lots\ +)?(?:of(?:\ +(.*))?)?)?$/, ast.interpret(context)
    assert_equal [:example, :id, :nesting], context
  end

  def test_back_to_back_optionals
    ast = @parser.parse("a [b] [c]")
#    assert_equal /a/, ast.interpret
    regex = ast.interpret
    assert regex.match("a")
    assert regex.match("a b")
    assert regex.match("a c")
    assert_equal nil, regex.match("ab")
    assert_equal nil, regex.match("ac")
  end
end
