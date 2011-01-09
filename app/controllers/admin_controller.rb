class AdminController < ApplicationController
  def login
    if request.post?
      agent = Agent.authenticate(params[:email1], params[:password])
      if agent
        session[:agent_id] = agent.id
        session[:email1] = params[:email1]
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || {:controller => "agents", :action => "show", :id => agent.id })
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    else
      params[:email1] = session[:email1]
    end
  end

  def logout
    session[:agent_id] = nil
    if session[:after_destroy_agent].blank?
      flash[:notice] = "Logged out"
    else
      flash[:notice] = "successfully deleted"
      session[:after_destroy_agent] = ""
    end
    redirect_to(:controller => "home")
  end

  def index
  end

end
