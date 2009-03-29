require File.dirname(__FILE__) + '/helper'

class TestBot < Test::Unit::TestCase
  def test_bot_complains_if_you_dont_provide_user_and_host
    assert_raise(RuntimeError) { Harken::Bot.new }
    assert_raise(RuntimeError) { Harken::Bot.new(:user => "roland") }
    assert_raise(RuntimeError) { Harken::Bot.new(:host => "localhost") }
    assert_nothing_raised(RuntimeError) { Harken::Bot.new(:user => "roland", :host => "localhost") }
  end
end
