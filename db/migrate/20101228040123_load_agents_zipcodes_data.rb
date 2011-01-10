require 'active_record/fixtures'

class LoadAgentsZipcodesData < ActiveRecord::Migration
  def self.up
    down
    directory = File.join(File.dirname(__FILE__), 'dev_data' )
    Fixtures.create_fixtures(directory, "agents_zipcodes" )
  end

  def self.down
    
  end
end


