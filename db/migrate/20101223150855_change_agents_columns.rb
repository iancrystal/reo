class ChangeAgentsColumns < ActiveRecord::Migration
  def self.up
    add_column :agents, :first_name, :string
    add_column :agents, :middle_name, :string
    add_column :agents, :last_name, :string
    add_column :agents, :suffix, :string
    add_column :agents, :physical_address1, :string
    add_column :agents, :physical_address2, :string
    add_column :agents, :physical_address_city, :string
    add_column :agents, :physical_address_state, :string
    add_column :agents, :physical_address_zip, :string
    add_column :agents, :mailing_address1, :string
    add_column :agents, :mailing_address2, :string
    add_column :agents, :mailing_address_city, :string
    add_column :agents, :mailing_address_state, :string
    add_column :agents, :mailing_address_zip, :string
    remove_column :agents, :name
    remove_column :agents, :physical_address
    remove_column :agents, :mailing_address
  end

  def self.down
    remove_column :agents, :first_name
    remove_column :agents, :middle_name
    remove_column :agents, :last_name
    remove_column :agents, :suffix
    remove_column :agents, :physical_address1
    remove_column :agents, :physical_address2
    remove_column :agents, :physical_address_city
    remove_column :agents, :physical_address_state
    remove_column :agents, :physical_address_zip
    remove_column :agents, :mailing_address1
    remove_column :agents, :mailing_address2
    remove_column :agents, :mailing_address_city
    remove_column :agents, :mailing_address_state
    remove_column :agents, :mailing_address_zip
    add_column :agents, :name, :string
    add_column :agents, :physical_address, :string
    add_column :agents, :mailing_address, :string
  end
end
