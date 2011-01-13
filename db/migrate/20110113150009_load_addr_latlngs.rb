require 'active_record/fixtures'

class LoadAddrLatlngs < ActiveRecord::Migration
  def self.up
    down
    directory = File.join(File.dirname(__FILE__), 'dev_data' )
    Fixtures.create_fixtures(directory, "addr_latlngs" )
  end

  def self.down
    AddrLatlng.delete_all
  end
end
