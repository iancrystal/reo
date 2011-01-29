require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  fixtures :asset_companies, :agents

  test "login agent" do
    john = agents(:john)
    post :login, :email => john.email1, :password => 'secret'
    assert_redirected_to agent_url(john.id)
    assert_equal john.id, session[:agent_id]
  end

  test "login agent bad password" do
    john = agents(:john)
    post :login, :email => john.email1, :password => 'secre'
    assert_equal flash[:notice],  "Invalid user/password combination"
  end

  test "login asset company" do
    juan = asset_companies(:juan)
    post :login, :email => juan.email, :password => 'secret'
    assert_redirected_to :controller => "home"
    assert_equal juan.id, session[:asset_company_id]
  end

  test "login asset company bad password" do
    juan = asset_companies(:juan)
    post :login, :email => juan.email, :password => 'secre'
    assert_equal flash[:notice],  "Invalid user/password combination"
  end

  test "logout" do
    get :logout
    assert_nil session[:agent_id]
    assert_nil session[:asset_company_id]
    assert_nil session[:admin_id]
    assert_equal flash[:notice],  "Logged out"
    assert_redirected_to :controller => "home"
  end

end
