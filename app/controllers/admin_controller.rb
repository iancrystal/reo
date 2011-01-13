class AdminController < ApplicationController
  def login
    if request.post?
      if assetc = AssetCompany.authenticate(params[:email], params[:password])
        if params[:email] == ADMIN
          session[:admin_id] = assetc.id
          session[:agent_id] = nil
          session[:asset_company_id] = nil
          # redirect to previous request
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || asset_companies_url)
        else 
          session[:asset_company_id] = assetc.id
          session[:admin_id] = nil
          session[:agent_id] = nil
          # redirect to previous request
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || :controller => "home" )
        end
      elsif agent = Agent.authenticate(params[:email], params[:password])
        session[:agent_id] = agent.id
        session[:admin_id] = nil
        session[:asset_company_id] = nil
        session[:email1] = params[:email] # used to prefil forms
        # redirect to previous request
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || agent_url(:id => agent.id))
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    else
      params[:email1] = session[:email1] # used to prefill login form
    end
  end

  def logout
    session[:agent_id] = nil
    session[:asset_company_id] = nil
    session[:admin_id] = nil
    if ! session[:after_destroy_agent].blank? || ! session[:after_destroy_asset_company].blank?
      flash[:notice] = "successfully deleted"
      session[:after_destroy_agent] = ""
    else
      flash[:notice] = "Logged out"
    end
    redirect_to(:controller => "home")
  end
  
  # since the before_filter form that passes the controller class (block and class) cannot access the flash, we just
  # use this as the temporary redirect
  def filter_login_redirect
    flash[:notice] = "Unauthorized access. Please log in"
    redirect_to(:action => "login")
  end
end
