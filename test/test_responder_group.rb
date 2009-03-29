require File.dirname(__FILE__) + '/helper'
require 'lib/responder'
require 'lib/responder_group'
require File.dirname(__FILE__) + '/dummy_responders'

class TestResponder < Test::Unit::TestCase
  def test_responder_group_composes_all_responders_by_default
    replies = Harken::ResponderGroup.new.receive("test")
    assert replies.include?("foo")
    assert replies.include?("second")
    assert ! replies.include?("baz")
  end

  def test_responder_group_can_be_composed_with_specific_classes
    replies = Harken::ResponderGroup.new(SimpleResponder).receive("test")
    assert replies.include?("foo")
    assert ! replies.include?("second")
  end
end
