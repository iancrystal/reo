require 'test_helper'

class AgentsControllerTest < ActionController::TestCase
  
  fixtures :agents

  test "should get new" do
    get :new
    assert_not_nil assigns["agent"].terms
    assert_response :success
    assert_template "new"
    assert_select "div.reo-form"
  end

  test "should post create" do
    assert_difference('Agent.count') do
      post :create, :agent => {:email1 => "create2@agent.com", :password => "secret"}
    end
    assert_redirected_to agent_path(assigns(:agent))
  end

  test "should get show" do
    get :show, :id => agents(:john).to_param
    assert_response :success
  end

  test "should not get edit if no login" do
    get :edit, :id => agents(:john).to_param
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should get edit but no member_status" do
    get :edit, {:id => agents(:john).id}, {:agent_id => agents(:john).id}
    assert_template "edit"
    assert_select "input#agent_member_status" , :count => 0
    assert_response :success
  end

  test "should get edit and has member_status" do
    get :edit, {:id => agents(:john).id}, {:admin_id => "something"}
    assert_template "edit"
    assert_select "input#agent_member_status" , :count => 1
    assert_response :success
  end

  test "should put update" do
    put :update, {:id => agents(:john).id, :agent => {:physical_address_zip => "95139"}}, {:agent_id => agents(:john).id}
    assert_equal Agent.find(agents(:john).id).physical_address_zip, "95139"
    assert_redirected_to agent_path(assigns(:agent))
  end

  test "should not put update" do
    put :update, {:id => agents(:john).id, :agent => {:physical_address_zip => "95139"}}
    assert_not_equal Agent.find(agents(:john).id).physical_address_zip, "95139"
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should not put update membership status if not admin" do
    put :update, {:id => agents(:john).id, :agent => {:member_status => 9}}, {:agent_id => agents(:john).id}
    assert_not_equal Agent.find(agents(:john).id).member_status, 9
    assert_equal flash[:notice], "only an admin can edit the membership status"
    assert_redirected_to :controller => "admin", :action => "filter_login_redirect"
  end

  test "should delete destroy" do
    assert_difference('Agent.count', -1) do
      delete :destroy, {:id => agents(:john).to_param}, {:agent_id => agents(:john).id}
    end
    assert_match(/successfully deleted/i, flash[:notice])
    assert_redirected_to :controller => "admin", :action => 'logout'
  end

  test "should not delete destroy" do
    assert_difference('Agent.count', 0) do
      delete :destroy, {:id => agents(:john).to_param}
    end
    assert_redirected_to :controller => 'admin', :action => 'filter_login_redirect'
  end
end
