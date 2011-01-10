require 'active_record/fixtures'

class LoadZipcodesData < ActiveRecord::Migration
  def self.up
    down
    directory = File.join(File.dirname(__FILE__), 'dev_data' )
    Fixtures.create_fixtures(directory, "zipcodes" )
  end

  def self.down
    Zipcode.delete_all
  end
end


