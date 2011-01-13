class AssetCompanyNotesController < ApplicationController

  # POST /asset_company_notes
  # POST /asset_company_notes.xml
  def create
    
    @asset_company_note = AssetCompanyNote.new(params[:asset_company_note])
    @asset_company_note.agent_id = session[:last_agent_shown]
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

  # for now just empty the notes instead of delete so no destroy action yet
  
end

