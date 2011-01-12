class AssetCompanyNotesController < ApplicationController

  # GET /asset_company_notes/1
  # GET /asset_company_notes/1.xml
  def show
    @asset_company_note = AssetCompanyNote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @asset_company_note }
    end
  end

  # GET /asset_company_notes/new
  # GET /asset_company_notes/new.xml
  def new
    @asset_company_note = AssetCompanyNote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @asset_company_note }
    end
  end

  # GET /asset_company_notes/1/edit
  def edit
    @asset_company_note = AssetCompanyNote.find(params[:id])

  end

  # POST /asset_company_notes
  # POST /asset_company_notes.xml
  def create
    
    @asset_company_note = AssetCompanyNote.new(params[:asset_company_note])
    @asset_company_note.agent_id = flash[:agent_id]
    @asset_company_note.asset_company_id = session[:asset_company_id]
    respond_to do |format|
      if @asset_company_note.save
        flash[:notice] = "Note was successfully created."
        format.html { redirect_to(agent_url(:id => @asset_company_note.agent_id)) }
        format.xml  { render :xml => @asset_company_note, :status => :created, :location => @asset_company_note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset_company_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /asset_company_notes/1
  # PUT /asset_company_notes/1.xml
  def update
    @asset_company_note = AssetCompanyNote.find(params[:id])
    respond_to do |format|
      if @asset_company_note.update_attributes(params[:asset_company_note])
        flash[:notice] = "Note by #{@asset_company_note.asset_company.company_name} was successfully updated"
        format.html { redirect_to(agent_url(:id => @asset_company_note.agent_id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @asset_company_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_company_notes/1
  # DELETE /asset_company_notes/1.xml
  def destroy
    # this automatically removes the entries in the asset_company_notes_zipcodes table of the asset_company_note being destroyed
    @asset_company_note = AssetCompanyNote.find(params[:id])
    
    @asset_company_note.destroy
    
    flash[:notice] = "note was successfully deleted"

    respond_to do |format|
      format.html { redirect_to(:controller => 'agents', :action => 'show', :id => @asset_company_note.agent.id ) }
      format.xml  { head :ok }
    end
  end
  
end