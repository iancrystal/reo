class AssetCompanyNote < ActiveRecord::Base
  belongs_to :asset_company
  belongs_to :agent
end