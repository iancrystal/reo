require 'active_record/fixtures'

class LoadAgentsData < ActiveRecord::Migration
  def self.up
    down
    directory = File.join(File.dirname(__FILE__), 'dev_data' )
    Fixtures.create_fixtures(directory, "agents" )
  end

  def self.down
    Agent.delete_all
  end
end
