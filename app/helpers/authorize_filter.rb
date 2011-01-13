class AuthorizeFilter < ActionController::Base

  def self.filter(controller)

    action = controller.action_name
    id = controller.params[:id].to_i
    session = controller.session
    request = controller.request
    
    # admin is like superuser - no restrictions
    if ! session[:admin_id]

        if controller.instance_of? AgentsController
          # there are pre-created agent accounts that still needs a password to be set. so we should allow anyone to 
          # access the edit/update action for these accounts so the owner can set the password. After the password
          # has been set only the authenticated owner can edit the account. This is still secure since the only way
          # to set session[:editing_nopassword_agent] is from the sign_up action which first verifies that the 
          # account has no password set yet.
          if action == "edit" || action == "update" || action == "destroy" 
            if session[:agent_id] != id  && ! session[:editing_nopassword_agent]
              session[:original_uri] = request.request_uri
              # filter_login_redirect just sets the flash before going to the login action because we can't set the flash here
              controller.send(:redirect_to, :controller => 'admin' , :action => 'filter_login_redirect')
            # reset the editing_no_password_agent token once update has been allowed
            elsif action == "update"
              session[:editing_nopassword_agent] = nil
            end
          end
          
        elsif controller.instance_of? AssetCompaniesController
          if session[:asset_company_id] != id
            session[:original_uri] = request.request_uri
            controller.send(:redirect_to, :controller => 'admin' , :action => 'filter_login_redirect')
          end
          
        elsif controller.instance_of? AssetCompanyNotesController
          if session[:asset_company_id] != session[:asset_company_id_of_note]
            session[:original_uri] = request.request_uri
            controller.send(:redirect_to, :controller => 'admin' , :action => 'filter_login_redirect')
          end 
        end
        
    end
        
  end

end
