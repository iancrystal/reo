require 'test_helper'

# other features/code in the Agent model gets covered in the functional tests

class AgentTest < ActiveSupport::TestCase

  fixtures :zipcodes

  test "invalid with empty attributes" do
    agent = Agent.new
    assert !agent.valid?
    assert agent.errors.invalid?(:email1)
  end

  test "unique email1" do
    agent = Agent.new(:email1 => agents(:john).email1)
    assert !agent.save
    assert_equal I18n.translate('activerecord.errors.messages.taken' ),
      agent.errors.on(:email1)
  end

  test "service areas" do
    agent = Agent.find(agents(:john).id)
    z92253 = zipcodes(:z92253)
    z92201 = zipcodes(:z92201)
    z92210 = zipcodes(:z92210)
    agent.service_areas = "#{z92253.zipcode.to_s} #{z92201.zipcode.to_s} #{z92210.zipcode.to_s}"
    # avoid tying up a certain service area format so just search for a match
    assert_match(/92253/,agent.service_areas)
    assert_match(/92201/,agent.service_areas)
    assert_match(/92210/,agent.service_areas)
  end

end

