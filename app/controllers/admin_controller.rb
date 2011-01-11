class AdminController < ApplicationController
  def login
    if request.post?
      if agent = Agent.authenticate(params[:email], params[:password])
        session[:agent_id] = agent.id
        session[:email1] = params[:email]
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || agent_url(:id => agent.id)) # :action => show
      elsif assetc = AssetCompany.authenticate(params[:email], params[:password])
        session[:asset_company_id] = assetc.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || asset_company_url(:id => assetc.id))
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    else
      params[:email1] = session[:email1]
    end
  end

  def logout
    session[:agent_id] = nil
    session[:asset_company_id] = nil
    if ! session[:after_destroy_agent].blank? || ! session[:after_destroy_asset_company].blank?
      flash[:notice] = "successfully deleted"
      session[:after_destroy_agent] = ""
    else
      flash[:notice] = "Logged out"
    end
    redirect_to(:controller => "home")
  end

  def index
  end

end
