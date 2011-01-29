require 'test_helper'

class AgentTest < ActiveSupport::TestCase

  test "invalid with empty attributes" do
    agent = Agent.new
    assert !agent.valid?
    assert agent.errors.invalid?(:email1)
  end

  test "unique email1" do
    Agent = Agent.new(:email1 => agents(:john).email1)
    assert !Agent.save
    assert_equal I18n.translate('activerecord.errors.messages.taken' ),
      Agent.errors.on(:email1)
  end

end

