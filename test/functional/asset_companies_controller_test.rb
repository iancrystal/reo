require 'test_helper'

class AssetCompaniesControllerTest < ActionController::TestCase

  fixtures :asset_companies

  test "index without user" do
    get :index
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "index with user" do
    get :index, {:id => asset_companies(:juan).id}, {:asset_company_id => asset_companies(:juan).id}
    assert_response :success
    assert_template "index"
  end

end

