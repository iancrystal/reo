class CreateAssetCompanyNotes < ActiveRecord::Migration
  def self.up
    create_table :asset_company_notes do |t|
      t.integer :agent_id
      t.integer :asset_company_id
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :asset_company_notes
  end
end
