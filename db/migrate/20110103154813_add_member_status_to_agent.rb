class AddMemberStatusToAgent < ActiveRecord::Migration
  def self.up
    add_column :agents, :member_status, :integer
  end

  def self.down
    remove_column :agents, :member_status
  end
end
