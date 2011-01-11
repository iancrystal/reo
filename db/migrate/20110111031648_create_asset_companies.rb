class CreateAssetCompanies < ActiveRecord::Migration
  def self.up
    create_table :asset_companies do |t|
      t.string :company_name
      t.string :email
      t.string :phone
      t.string :fax
      t.string :contact_name
      t.string :address1
      t.string :address2
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.string :hashed_password
      t.string :salt
      
      t.timestamps
    end
  end

  def self.down
    drop_table :asset_companies
  end
end
