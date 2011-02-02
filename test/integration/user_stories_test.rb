require 'test_helper'

class UserStoriesTest < ActionController::IntegrationTest
  fixtures :all

  test "sign up to search" do
    post "/home/sign_up", {:email1 => "newbie@test.com"}
    assert_redirected_to new_agent_url

    get "/agents/new"
    assert_not_nil assigns["agent"].terms
    assert_response :success
    assert_template "new"
    assert_select "div.reo-form"

    assert_difference('Agent.count') do
      post "/agents/create", :agent => {:email1 => "newbie@test.com", :password => "secret", :first_name => "Newbie", :last_name => "Dude", :zip_codes => "92210 92201"}
    end
    assert_redirected_to agent_path(assigns(:agent))

    new = Agent.find(:first, :conditions => "email1 = 'newbie@test.com'")
    post "/home/index", {:address => "92253"}
    assert_select "a[href=/agents/#{new.id}]", "#{new.first_name} #{new.last_name}"
  end

end
