# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110110031025) do

  create_table "agents", :force => true do |t|
    t.string   "company"
    t.string   "email1"
    t.string   "email2"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "fax"
    t.text     "bio_cred"
    t.string   "photo_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "suffix"
    t.string   "physical_address1"
    t.string   "physical_address2"
    t.string   "physical_address_city"
    t.string   "physical_address_state"
    t.string   "physical_address_zip"
    t.string   "mailing_address1"
    t.string   "mailing_address2"
    t.string   "mailing_address_city"
    t.string   "mailing_address_state"
    t.string   "mailing_address_zip"
    t.integer  "member_status"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "resume_filename"
  end

  add_index "agents", ["email1"], :name => "index_agents_on_email1"

  create_table "agents_zipcodes", :id => false, :force => true do |t|
    t.integer "agent_id"
    t.integer "zipcode_id"
  end

  add_index "agents_zipcodes", ["agent_id", "zipcode_id"], :name => "index_agents_zipcodes_on_agent_id_and_zipcode_id", :unique => true
  add_index "agents_zipcodes", ["zipcode_id"], :name => "index_agents_zipcodes_on_zipcode_id"

  create_table "zipcodes", :force => true do |t|
    t.integer  "zipcode"
    t.decimal  "lat",        :precision => 7, :scale => 5
    t.decimal  "lng",        :precision => 8, :scale => 5
    t.string   "state"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
