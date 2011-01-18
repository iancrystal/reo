class AddAgentIndextToAddrLatlng < ActiveRecord::Migration
  def self.up
    add_index :addr_latlngs, :agent_id
  end

  def self.down
    remove_index :addr_latlngs, :agent_id
  end
end
