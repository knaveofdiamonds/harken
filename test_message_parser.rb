require 'treetop'
require 'polyglot'
require 'message'
require 'test/unit'

class Treetop::Runtime::SyntaxNode
  def interpret
    elements.map {|e| e.interpret }.join if nonterminal?()
  end
end

class TestMessageParser < Test::Unit::TestCase
  def setup
    @parser = MessageParser.new
  end

  def test_string
    ast = @parser.parse("Hello, world!")
    assert_equal /Hello,\ world!/, ast.interpret
  end

  def test_identifier
    ast = @parser.parse("<id>")
    assert_equal /(.*)/, ast.interpret
  end

  def test_optional
    ast = @parser.parse("[name]")
    assert_equal /(?:name)?/, ast.interpret
  end

  def test_composite_expression
    ast = @parser.parse("hello [[some] <person>]")
    assert_equal /hello\ (?:(?:some)?\ (.*))?/, ast.interpret
  end

  def test_strings_are_regexp_escaped
    ast = @parser.parse("dr. foo")
    assert_equal /dr\.\ foo/, ast.interpret
  end
end
