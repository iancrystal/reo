require 'test_helper'

class AssetCompanyNotesControllerTest < ActionController::TestCase

  fixtures :asset_companies, :agents

  test "should post create" do
    john = agents(:john)
    juan = asset_companies(:juan) 
    assert_difference('AssetCompanyNote.count', 1) do
      post :create, {:asset_company_note => {:note => "test note"}}, {:last_agent_shown => john.id, :asset_company_id => juan.id, :asset_company_id_of_note => juan.id}
    end
    assert_equal flash[:notice], "Note was successfully created."
    assert_redirected_to agent_path(john.id)
  end

  test "should not post create" do
    john = agents(:john)
    juan = asset_companies(:juan) 
    assert_difference('AssetCompanyNote.count', 0) do
      post :create, {:asset_company_note => {:note => "test note"}}, {:last_agent_shown => john.id, :asset_company_id => juan.id}
    end
    assert_redirected_to :action => "filter_login_redirect"
  end

  test "should put update" do
    john = agents(:john)
    juan = asset_companies(:juan) 
    post :create, {:asset_company_note => {:note => "test note"}}, {:last_agent_shown => john.id, :asset_company_id => juan.id, :asset_company_id_of_note => juan.id}
    note = AssetCompanyNote.find(:first, :conditions => "agent_id = #{john.id} and asset_company_id = #{juan.id}")
    put :update, {:id => note.id, :asset_company_note => {:note => "the update"}}, {:asset_company_id => juan.id, :asset_company_id_of_note => juan.id}
    updated = AssetCompanyNote.find(note.id)
    assert_equal updated.note, "the update"
    assert_match(/was successfully updated/i, flash[:notice])
    assert_redirected_to agent_path(john.id)
  end

  test "should not put update" do
    john = agents(:john)
    juan = asset_companies(:juan) 
    post :create, {:asset_company_note => {:note => "test note"}}, {:last_agent_shown => john.id, :asset_company_id => juan.id, :asset_company_id_of_note => juan.id}
    note = AssetCompanyNote.find(:first, :conditions => "agent_id = #{john.id} and asset_company_id = #{juan.id}")
    put :update, {:id => note.id, :asset_company_note => {:note => "the update"}}, {:asset_company_id => juan.id}
    updated = AssetCompanyNote.find(note.id)
    assert_not_equal updated.note, "the update"
    assert_redirected_to :action => "filter_login_redirect"
  end

end
