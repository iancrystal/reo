class CreateAgentsZipcodes < ActiveRecord::Migration
  def self.up
    create_table :agents_zipcodes, :id => false do |t|
      t.integer :agent_id
      t.integer :zipcode_id
    end
    add_index :agents_zipcodes, [:agent_id, :zipcode_id], :unique => true
    add_index :agents_zipcodes, :zipcode_id, :unique => false
  end

  def self.down
    drop_table :agents_zipcodes
  end
end
