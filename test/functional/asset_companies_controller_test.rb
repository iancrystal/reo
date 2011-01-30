require 'test_helper'

class AssetCompaniesControllerTest < ActionController::TestCase

  fixtures :asset_companies

  test "should not get index" do
    get :index
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should get index" do
    get :index, {}, {:admin_id => 1}
    assert_response :success
    assert_template "index"
  end

  test "should get new" do
    get :new, {}, {:admin_id => 1}
    assert_not_nil assigns["asset_company"]
    assert_response :success
    assert_template "new"
  end

  test "should not get new" do
    get :new
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should get show" do
    get :show, {:id => asset_companies(:juan).id}, {:asset_company_id => asset_companies(:juan).id }
    assert_response :success
    assert_template "show"
  end

  test "should not get show" do
    get :show, :id => asset_companies(:juan).id
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should get edit" do
    get :edit, {:id => asset_companies(:juan).id}, {:asset_company_id => asset_companies(:juan).id }
    assert_response :success
    assert_template "edit"
  end

  test "should not get edit" do
    get :edit, :id => asset_companies(:juan).id
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should post create" do
    assert_difference('AssetCompany.count', 1) do
     post :create, {:asset_company => {:email => "create1@asset_company.com", :password => "secret"}}, {:admin_id => "1"}
    end
    assert_redirected_to asset_company_path(assigns(:asset_company))
  end

  test "should not post create" do
    assert_difference('AssetCompany.count', 0) do
     post :create, {:asset_company => {:email => "create1@asset_company.com", :password => "secret"}}, {:asset_company_id => asset_companies(:juan).id }
    end
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should put update" do
    put :update, {:id => asset_companies(:juan).id, :asset_company => {:address_zip => "95139"}}, {:asset_company_id => asset_companies(:juan).id}
    assert_equal AssetCompany.find(asset_companies(:juan).id).address_zip, "95139"
    assert_redirected_to asset_company_path(assigns(:asset_company))
  end

  test "should not put update" do
    put :update, {:id => asset_companies(:juan).id, :asset_company => {:address_zip => "95139"}}
    assert_not_equal AssetCompany.find(asset_companies(:juan).id).address_zip, "95139"
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should delete destroy" do
    assert_difference('AssetCompany.count', -1) do
      delete :destroy, {:id => asset_companies(:juan).id}, {:asset_company_id => asset_companies(:juan).id}
    end
    assert_match(/successfully deleted/i, flash[:notice])
    assert_redirected_to :controller => "admin", :action => 'logout'
  end

  test "should not delete destroy" do
    assert_difference('AssetCompany.count', 0) do
      delete :destroy, {:id => asset_companies(:juan).id}
    end
    assert_redirected_to :action => "filter_login_redirect"
  end

end
