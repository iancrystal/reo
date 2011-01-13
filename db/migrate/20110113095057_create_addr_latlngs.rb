class CreateAddrLatlngs < ActiveRecord::Migration
  def self.up
    create_table :addr_latlngs do |t|
      t.integer :agent_id
      t.decimal :lat, :precision => 7, :scale => 5
      t.decimal :lng, :precision => 8, :scale => 5
    end
  end

  def self.down
    drop_table :addr_latlng
  end
end
