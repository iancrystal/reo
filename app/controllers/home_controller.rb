require 'rubygems'
require 'geokit'

# Contains the map searh, sign-up and advanced search actions
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

      g=Geokit::Geocoders::YahooGeocoder.geocode @address
      coord = [g.lat, g.lng]
      @map.center_zoom_init(coord,11)

      @found_agents = [];
      # get the zipcodes within the 5 mile radius
      zips = Zipcode.find(:all, :origin => coord, :within=> 5)
      zips.each do |zip|
        agents = zip.agents
        # get the agents of each zipcode
        agents.each do |agent|
          found = @found_agents.detect {|a| a.id == agent.id}
          if found.blank?
            @found_agents << agent
            # use the zipcode lat/lng if cannot get the lat/lng of physical address 
            # or if physical address is too far
            coord = [zip.lat, zip.lng]
            # get the geo lat lng to create the marker for each agent.  check addr_latlng first then the geo web 
            # service then as last resort just use the geo of the zipcode table
            if agent.latlng_good? 
              coord = [agent.addr_latlng.lat, agent.addr_latlng.lng]
            else
              agent.set_latlng!
              if agent.latlng_good? 
                coord = [agent.addr_latlng.lat, agent.addr_latlng.lng]  
              end
            end
            if agent.latlng_good? 
              # if the physical address is to far just use the zip code service area
              # so the marker still shows up in the map
              d = g.distance_to([agent.addr_latlng.lat, agent.addr_latlng.lng], :units => :miles)
              if (d > 10)
                coord = [zip.lat, zip.lng]
              end
            end
            @map.overlay_init(GMarker.new(coord, :title => "#{agent.first_name} #{agent.last_name}",
              :info_window => "<b>#{agent.first_name} #{agent.last_name}</b><br> #{agent.phone1}<br>#{agent.email1}<br>
                <a href=\"/agents/#{agent.id}\" onclick=\"Element.show('spinner'); new Ajax.Updater('agent_profile', '/agents/#{agent.id}', {asynchronous:true, evalScripts:true, method:'get', onComplete:function(request){Element.hide('spinner')}, parameters:'authenticity_token=' + encodeURIComponent('nNJoKK3O6kpWMtOXgC+nnxsg23wruU80fTJ6I2HpmCI=')}); return false;\">Link to Profile</a>"))
          end
        end
      end
      @temp = @found_agents.sort_by { |a| [a.first_name, a.last_name] }
      @found_agents = @temp
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
          session[:editing_nopassword_agent] = true
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
    if request.post?
      sql = ""
      sql_params = []

      # mysql (development) like is case insensitive, postgresql (production/heroku) uses ilike which is not supported 
      # in mysql. this is set in config/environments/development.rb, production.rb and test.rb
      like = LIKE

      if ! params[:name].blank?
        sql += "(first_name #{like} ? or middle_name #{like} ? or last_name #{like} ?) and "
        sql_params << "%"+params[:name]+"%" << "%"+params[:name]+"%" << "%"+params[:name]+"%"
      end
      if ! params[:company].blank?
        sql += "(company #{like} ?) and "
        sql_params << "%"+params[:company]+"%"
      end
      if ! params[:street].blank?
        sql += "(physical_address1 #{like} ? or physical_address2 #{like} ? or mailing_address1 #{like} ? or mailing_address2 #{like} ?) and "
        sql_params << "%"+params[:street]+"%" << "%"+params[:street]+"%" << "%"+params[:street]+"%" << "%"+params[:street]+"%"
      end
      if ! params[:city].blank?
        sql += "(physical_address_city #{like} ? or mailing_address_city #{like} ?) and "
        sql_params << "%"+params[:city]+"%" << "%"+params[:city]+"%"
      end
      if ! params[:state].blank?
        sql += "(physical_address_state #{like} ? or mailing_address_state #{like} ?) and "
        sql_params << "%"+params[:state]+"%" << "%"+params[:state]+"%"
      end
      if ! params[:zip].blank?
        sql += "(physical_address_zip #{like} ? or mailing_address_zip #{like} ?) and "
        sql_params << "%"+params[:zip]+"%" << "%"+params[:zip]+"%"
      end
      if ! params[:email].blank?
        sql += "(email1 #{like} ? or email2 #{like} ?) and "
        sql_params << "%"+params[:email]+"%" << "%"+params[:email]+"%"
      end
      if ! params[:phone].blank?
        sql += "(phone1 #{like} ? or phone2 #{like} ?) and "
        sql_params << "%"+params[:email]+"%" << "%"+params[:email]+"%"
      end
      if ! params[:fax].blank?
        sql += "(fax #{like} ?) and "
        sql_params << "%"+params[:fax]+"%"
      end
      if ! params[:bio_cred].blank?
        sql += "(bio_cred #{like} ?)"
        sql_params << "%"+params[:bio_cred]+"%"
      end

      if ! sql.blank?
        agents = Agent.find(:all, :conditions => [sql.gsub!(/ and $/, '')] + sql_params,
          :order => "first_name, last_name", :limit => 30)

        @found_agents = []
        agents.each do |agent|
          found = @found_agents.detect {|a| a.id == agent.id}
          if found.blank?
            @found_agents << agent        
          end
        end
      end
    end
  end

  def support_contact
  end

end
