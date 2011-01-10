class CreateAgents < ActiveRecord::Migration
  def self.up
    create_table :agents do |t|
      t.string :name
      t.string :company
      t.text :physical_address
      t.text :mailing_address
      t.string :email1
      t.string :email2
      t.string :phone1
      t.string :phone2
      t.string :fax
      t.text :bio_cred
      t.string :photo_url

      t.timestamps
    end
  end

  def self.down
    drop_table :agents
  end
end
