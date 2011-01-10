class AddEmail1IndexToAgents < ActiveRecord::Migration
  def self.up
    add_index :agents, :email1
  end

  def self.down
    remove_index :agents, :email1
  end
end
