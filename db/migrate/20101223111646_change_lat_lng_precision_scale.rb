class ChangeLatLngPrecisionScale < ActiveRecord::Migration
  def self.up
    change_column :zipcodes, :lat, :decimal, :precision => 7, :scale => 5
    change_column :zipcodes, :lng, :decimal, :precision => 8, :scale => 5
  end

  def self.down
    change_column :zipcodes, :lat, :decimal, :precision => 10, :scale => 0
    change_column :zipcodes, :lng, :decimal, :precision => 10, :scale => 0
  end
end
