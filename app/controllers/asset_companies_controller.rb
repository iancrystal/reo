# Standard ReST interface to the asset_companies table.
class AssetCompaniesController < ApplicationController

  # GET /asset_companies
  # GET /asset_companies.xml
  def index
    @asset_companies = AssetCompany.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @asset_companies }
    end
  end

  # GET /asset_companies/1
  # GET /asset_companies/1.xml
  def show

    @asset_company = AssetCompany.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @asset_company }
    end
  end

  # GET /asset_companies/new
  # GET /asset_companies/new.xml
  def new
    @asset_company = AssetCompany.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @asset_company }
    end
  end

  # GET /asset_companies/1/edit
  def edit
    @asset_company = AssetCompany.find(params[:id])
  end

  # POST /asset_companies
  # POST /asset_companies.xml
  def create

    @asset_company = AssetCompany.new(params[:asset_company])
    respond_to do |format|
      if @asset_company.save
        #session[:asset_company_id] = @asset_company.id
        flash[:notice] = "Account for #{@asset_company.company_name} was successfully created."
        format.html { redirect_to(:action=>'show', :id => @asset_company.id) }
        format.xml  { render :xml => @asset_company, :status => :created, :location => @asset_company }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset_company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /asset_companies/1
  # PUT /asset_companies/1.xml
  def update
    @asset_company = AssetCompany.find(params[:id])        
    respond_to do |format|
      if @asset_company.update_attributes(params[:asset_company])
        flash[:notice] = "#{@asset_company.company_name} was successfully updated"
        format.html { redirect_to(:action=>'show', :id => @asset_company.id ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @asset_company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_companies/1
  # DELETE /asset_companies/1.xml
  def destroy
    # this automatically removes the entries in the asset_company_notes table of the asset_company being destroyed
    @asset_company = AssetCompany.find(params[:id])
    @asset_company.destroy

    flash[:notice] = "#{@asset_company.company_name} was successfully deleted"
    respond_to do |format|
      session[:after_destroy_asset_company] = "yes"
      format.html { redirect_to(:controller => 'admin', :action => 'logout') }
      format.xml  { head :ok }
    end
  end

end
