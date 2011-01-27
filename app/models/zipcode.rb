# Model for the zipcodes table
class Zipcode < ActiveRecord::Base
  acts_as_mappable
  has_and_belongs_to_many :agents
end
