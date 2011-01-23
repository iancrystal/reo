class AddAgentLicenseColumns < ActiveRecord::Migration
  def self.up
    add_column :agents, :license_type, :integer
    add_column :agents, :license_number, :integer
    add_column :agents, :license_issued, :date
    add_column :agents, :license_expires, :date
  end

  def self.down
    remove_column :agents, :license_type
    remove_column :agents, :license_number
    remove_column :agents, :license_issued
    remove_column :agents, :license_expires
  end
end
