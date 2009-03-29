require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/dummy_responders'

class TestResponder < Test::Unit::TestCase
  def test_simple_responder_responds_to_message
    assert_equal ["foo"], SimpleResponder.new.receive("test")
  end

  def test_simple_responder_ignores_message
    assert_equal [], SimpleResponder.new.receive("blob")
  end
  
  def test_duplicate_responder_responds_to_message
    assert_equal ["second"], DuplicateResponder.new.receive("test")
  end

  def test_with_variable
    assert_equal ["value is 'hello world'"], SimpleResponder.new.receive("test hello world")
  end

  def test_all_responders_are_tracked
    assert_equal [SimpleResponder, DuplicateResponder], Harken::Responder.all
  end
end
