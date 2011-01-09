require 'rubygems'
require 'geokit'

class HomeController < ApplicationController
  def index

    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)

    if ! request.post? &&  ! session[:address]
      # initial page

      # geographic center of the united states: lebanon, kansas
      @map.center_zoom_init([39.8284168,-98.5983505],4)

    else
      # post request - search address or address not empty

      if ! params[:address].blank?
        session[:address] = params[:address]
      end
      @address = session[:address]

      #Geocoding api is flaky so use Geokit api
      #results = Geocoding::get(@address)
      #if results.status == Geocoding::GEO_SUCCESS
      #coord = results[0].latlon

      a=Geokit::Geocoders::GoogleGeocoder.geocode @address
      coord = [a.lat, a.lng]
      @map.center_zoom_init(coord,9)

      @area_agents = [];
      # get the zipcodes within the 50 mile radius
      zips = Zipcode.find(:all, :origin => coord, :within=>50)
      zips.each do |zip|
        agents = zip.agents
        # get the agents of each zipcode
        agents.each do |agent|
          found = @area_agents.detect {|a| a.id == agent.id}
          if found.blank?
            @area_agents << agent;
            # create the marker for each agent
            coord = [zip.lat, zip.lng]
            @map.overlay_init(GMarker.new(coord, :title => "#{agent.first_name} #{agent.last_name}", :info_window => "<b>#{agent.first_name} #{agent.last_name}</b><br> #{agent.phone1}<br>#{agent.email1}<br><a href=\"/agents/show/#{agent.id}\">profile</a>"))
          end
        end
      end
    end
  end
  
  def sign_up
    if request.post?
      session[:email1] = params[:email1]
      agent = Agent.find_by_email1(params[:email1])
      if agent
        # account exists
        if ! agent.hashed_password.blank?
          # account exists and already has a password
          flash[:notice] = "Account already signed up. You may login or sign-up again and enter another email"
          redirect_to(:controller => "admin", :action => "login")
        else
          # account exists but no password yet
          flash[:notice] = "Account exists but no password has been set. You may edit the existing information"
          redirect_to(edit_agent_url(:id => agent.id))
        end
      else
        # account does not exist
        redirect_to(new_agent_url)
      end
    else
      params[:email1] = session[:email1]
    end
  end
  
  def advanced_search
  end
  
  def support_contact
  end

  protected
  
  # overrides the authorize of admin class to do nothing since the operations here do not need authentication. (we are using the whitelist technique)
  def authorize
  end

end
