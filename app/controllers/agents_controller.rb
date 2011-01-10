require 'aws/s3'

class AgentsController < ApplicationController

  # GET /agents/1
  # GET /agents/1.xml
  def show
=begin
    aws_s3_connect
    if AWS::S3::S3Object.exists? "photo15580", 'reoagentphoto'
      puts "photo15580 exists"
    else
      puts "photo15580 does not exist"
    end
=end
    
    @agent = Agent.find(params[:id])
    @service_areas = @agent.service_areas
    
    aws_s3_connect
    
    @resume_url = @agent.resume_url
    if ! @resume_url.blank?
        if ! AWS::S3::S3Object.exists? @agent.resume_filename, 'reoagentresume'
          @resume_url = ""
        end
    end
    
    @photo_url = @agent.photo_url
    if ! @photo_url.blank?
        if ! AWS::S3::S3Object.exists? @agent.photo_filename, 'reoagentphoto'
          @photo_url = ""
        end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agent }
    end
  end

  # GET /agents/new
  # GET /agents/new.xml
  def new
    @agent = Agent.new
    @agent.email1 = session[:email1]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agent }
    end
  end

  # GET /agents/1/edit
  def edit
    @agent = Agent.find(params[:id])
    @agent.zip_codes = @agent.service_zips
  end

  # POST /agents
  # POST /agents.xml
  def create
    
    @agent = Agent.new(params[:agent])
    respond_to do |format|
      if @agent.save
        @agent.service_areas = params[:agent][:zip_codes]
        if ! @agent.photo_data.blank?
          # now that we have the id, save the photo_url
          @agent.photo_url = "/images/photo" + @agent.id.to_s
          # save the photo to amazon s3 reoagentphoto bucket
          aws_s3_connect
          save_photo_to_aws_s3
        end
        if ! @agent.resume_data.blank?
          @agent.resume_filename = "resume" + @agent.id.to_s + "." + @agent.resume_ext
          # save the photo to amazon s3 reoagentphoto bucket
          aws_s3_connect
          save_resume_to_aws_s3
        end
        if ! @agent.photo_data.blank? || ! @agent.resume_data.blank?
          @agent.save
        end
        session[:agent_id] = @agent.id
        flash[:notice] = "User #{@agent.first_name} #{@agent.last_name} was successfully created."
        format.html { redirect_to(:action=>'show', :id => @agent.id) }
        format.xml  { render :xml => @agent, :status => :created, :location => @agent }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agents/1
  # PUT /agents/1.xml
  def update
    @agent = Agent.find(params[:id])
        
    if authorize(@agent.id, "/agents/edit/" + @agent.id.to_s)
        respond_to do |format|

          if @agent.update_attributes(params[:agent])
          
            # this magically updates the zipcodes and habtm agents_zipcodes tables
            @agent.service_areas = params[:agent][:zip_codes]
            
            if ! @agent.photo_data.blank? || ! @agent.resume_data.blank?
              aws_s3_connect
            end
            if ! @agent.photo_data.blank?
              @agent.photo_url = "/images/photo" + @agent.id.to_s              
              save_photo_to_aws_s3
            end

            if ! @agent.resume_data.blank?
              @agent.resume_filename = "resume" + @agent.id.to_s + "." + @agent.resume_ext
              save_resume_to_aws_s3
            end
            if ! @agent.photo_data.blank? || ! @agent.resume_data.blank?
              @agent.save
            end

            flash[:notice] = "User #{@agent.first_name} #{@agent.last_name} was successfully updated"
            format.html { redirect_to(:action=>'show', :id => @agent.id ) }
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @agent.errors, :status => :unprocessable_entity }
          end
        end
    else
        redirect_to :controller => 'admin' , :action => 'login'
    end
  end

  # DELETE /agents/1
  # DELETE /agents/1.xml
  def destroy
    # this automatically removes the entries in the agents_zipcodes table of the agent being destroyed
    @agent = Agent.find(params[:id])
    if authorize(@agent.id, "/agents/destroy/" + @agent.id.to_s)
        if ! @agent.photo_url.blank?
          aws_s3_connect
          delete_aws_s3_photo
        end
        if ! @agent.resume_filename.blank?
          aws_s3_connect
          delete_aws_s3_resume
        end
        
        @agent.destroy
        
        flash[:notice] = "User #{@agent.first_name} #{@agent.last_name} was successfully deleted"

        respond_to do |format|
          session[:after_destroy_agent] = "yes"
          format.html { redirect_to(:controller => 'admin', :action => 'logout') }
          format.xml  { head :ok }
        end
    else
        redirect_to :controller => 'admin' , :action => 'login'
    end
  end

  protected
  
  def authorize(id,original_uri)
    if (session[:agent_id] != id)
        session[:original_uri] = original_uri
        flash[:notice] = "Please log in"
        false
    else
        true
    end
  end
  
  def aws_s3_connect
    AWS::S3::Base.establish_connection!(
      :access_key_id     => 'AKIAIOLMS62WKQM2NQ2A',
      :secret_access_key => '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'
    ) 
  end
  
  # these should be refactored as more file types are added
  
  def save_photo_to_aws_s3
    AWS::S3::S3Object.store("photo" + @agent.id.to_s, @agent.photo_data, 'reoagentphoto', :access => :public_read)
  end
  
  def save_resume_to_aws_s3
    AWS::S3::S3Object.store(@agent.resume_filename, @agent.resume_data, 'reoagentresume', :access => :public_read)
  end
  
  def delete_aws_s3_photo
    if AWS::S3::S3Object.exists? "photo" + @agent.id.to_s, 'reoagentphoto'
      AWS::S3::S3Object.delete "photo" + @agent.id.to_s, 'reoagentphoto'
      logger.info "deleting photo" + @agent.id.to_s
    else
      logger.info "photo" + @agent.id.to_s + " does not exist"
    end
  end
  def delete_aws_s3_resume
    if AWS::S3::S3Object.exists? @agent.resume_filename, 'reoagentresume'
      AWS::S3::S3Object.delete @agent.resume_filename, 'reoagentresume'
      logger.info "deleting #{@agent.resume_filename}"
    else
      logger.info "#{@agent.resume_filename} does not exist"
    end
  end
  
end
