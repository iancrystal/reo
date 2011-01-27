# Model for the asset_company_note table
class AssetCompanyNote < ActiveRecord::Base
  belongs_to :asset_company
  belongs_to :agent
end
