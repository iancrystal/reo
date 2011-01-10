class AddResumeFilenameToAgents < ActiveRecord::Migration
  def self.up
    add_column :agents, :resume_filename, :string
  end

  def self.down
    remove_column :agents, :resume_filename
  end
end
