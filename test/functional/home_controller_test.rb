require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  fixtures :zipcodes, :agents

  test "should get index" do
    get :index
    assert_template "index"
  end

  test "should geo search agents" do
    john = Agent.find(agents(:john).id)
    mary = Agent.find(agents(:mary).id)
    z92253 = zipcodes(:z92253)
    z92201 = zipcodes(:z92201)
    z92210 = zipcodes(:z92210)
    john.service_areas = "#{z92253.zipcode.to_s} #{z92201.zipcode.to_s}"
    mary.service_areas = "#{z92210.zipcode.to_s}"
    post :index, {:address => "92253"}
    assert_response :success
    #puts @response.body
    assert_select "a[href=/agents/#{john.id}]", "#{john.first_name} #{john.last_name}"
    assert_select "a[href=/agents/#{mary.id}]", "#{mary.first_name} #{mary.last_name}"
  end

  test "should not sign up when account exists" do
    post :sign_up, {:email1 => agents(:mary).email1}
    assert_redirected_to :action => "login"
    assert_match(/already signed up/, flash[:notice])
  end

  test "should sign up when account has no password" do
    post :sign_up, {:email1 => agents(:nopassword).email1}
    assert_redirected_to edit_agent_url(agents(:nopassword).id)
    assert_equal true, session[:editing_nopassword_agent]
  end

  test "should sign up when no account" do
    post :sign_up, {:email1 => "noaccount"}
    assert_redirected_to new_agent_url
  end

  test "should post advanced_search" do
    mary = agents(:mary)
    post :advanced_search, {:company => "remax"}
    assert_response :success
    #puts @response.body
    assert_select "a[href=/agents/#{mary.id}]", "#{mary.first_name} #{mary.last_name}"
  end

  test "should post advanced_search 2 fields" do
    john = agents(:john)
    post :advanced_search, {:name => "doe", :city => "san jose"}
    assert_response :success
    #puts @response.body
    assert_select "a[href=/agents/#{john.id}]", "#{john.first_name} #{john.last_name}"
  end

end
