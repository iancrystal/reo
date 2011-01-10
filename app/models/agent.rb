require 'digest/sha1'
require 'geokit'

class Agent < ActiveRecord::Base
  has_and_belongs_to_many :zipcodes
  
  validates_presence_of :email1
  validates_uniqueness_of :email1
  validates_confirmation_of :password
  validate :password_non_blank
  validates_format_of :photo_type,
    :with => /^image/,
    :message => "--- you can only upload pictures",
    :unless => Proc.new { |u| u.photo_type.blank? }
  validates_format_of :zip_codes,
    :with => /^\s*[0-9]{5}(\s+[0-9]{5})*\s*$/,
    :message => "--- service area zipcodes should only be 5 digit numbers separated by spaces",
    :unless => Proc.new { |u| u.zip_codes.blank? }
    
  attr_accessor :password_confirmation
  attr_accessor :photo_type
  attr_accessor :photo_data
  attr_accessor :resume_type
  attr_accessor :resume_data
  attr_accessor :resume_ext
  attr_accessor :zip_codes

  def service_areas
	# get the service areas. example: Hayward, CA: 94544, 94545; San Jose, CA: 95134, 95135

	# first let's put all zipcode city and state info in a hash for quick access
    areas_zips = {}
    areas_city = {}
    areas_state = {}
    self.zipcodes.each do |zip|
      areas_zips["#{zip.city}#{zip.state}"] = "#{zip.zipcode} #{areas_zips["#{zip.city}#{zip.state}"]}"
      areas_city["#{zip.city}#{zip.state}"] = zip.city 
      areas_state["#{zip.city}#{zip.state}"] = zip.state
    end

	# then assemble the string by traversing each city-state key
	service_areas = []
    areas_zips.keys.each do |key|
      service_areas << "#{areas_city[key]}, #{areas_state[key]}: #{areas_zips[key]}"
    end
	service_areas.join("; ")

  end
  
  def service_zips
    zips = []
    self.zipcodes.each do |zip|
      zips << zip.zipcode
    end
    zips.join(" ")
  end
  
  def service_areas=(zipargs)
      # update the agents_zipcodes table and the zipcodes table based on the zipargs argument
      
      self.zipcodes = []
      zipargs.split(/\s+/).each do |arg|
          z = Zipcode.find_by_zipcode(arg)
          if ! z
            logger.info arg.to_s + " not found in zipcodes table."
            a=Geokit::Geocoders::YahooGeocoder.geocode arg
            if a.lat
              z = Zipcode.new(:zipcode => arg, :lat => a.lat, :lng => a.lng, :state => a.state, :city => a.city)
            else
              logger.info "cannot get info for #{arg}"
            end
          end
          if z
            if ! self.zipcodes.find_by_zipcode(arg)
              # this automatically creates an entry in the agents_zipcodes and zipcodes table
              self.zipcodes << z
            else
              logger.info arg.to_s + " is already a service area for " + self.first_name + " " + self.last_name
            end
          else
            logger.info "failed to add #{arg}"
          end
      end
  end
  
  def photo_url
    # facade to access amazon s3 location because heroku is read only
    url = read_attribute("photo_url")
	if ! url.blank?
      url.gsub(/\/images\//,"http:\/\/s3.amazonaws.com\/reoagentphoto\/")
    else
      ""
    end
  end
  
  def photo_filename
    # facade to access filename of photo
    url = read_attribute("photo_url")
	if ! url.blank?
      url.gsub(/\/images\//,"")
    else
      ""
    end
  end
  
  def resume_url
    name = read_attribute("resume_filename")
    if ! name.blank?
      "http://s3.amazonaws.com/reoagentresume/#{name}"
    else
      ""
    end
  end

  def self.authenticate(email1, password)
    agent = self.find_by_email1(email1)
    if agent
      # the salt and hashed_password is blank if the account exist but not yet verified
      if agent.salt.blank? || agent.hashed_password.blank?
        agent = nil
      else
        expected_password = encrypted_password(password, agent.salt)
        if agent.hashed_password != expected_password
          agent = nil
        end
      end
    end
    agent
  end
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Agent.encrypted_password(self.password, self.salt)
  end

  def uploaded_picture=(picture_field)
    self.photo_type = picture_field.content_type.chomp
    self.photo_data = picture_field.read
  end
  
  def uploaded_resume=(resume_field)
    self.resume_ext = ext_part_of(resume_field.original_filename)
    self.resume_type = resume_field.content_type.chomp
    self.resume_data = resume_field.read
  end
      
  private
  
  def password_non_blank
    errors.add(:password, "Missing password" ) if hashed_password.blank?
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def ext_part_of(file_name)
    File.basename(file_name).gsub(/.*\./, '' )
  end

end
