require 'digest/sha1'
require 'geokit'

class Agent < ActiveRecord::Base
  has_and_belongs_to_many :zipcodes
  # delete_all is for faster delete. this is safe since a company note has not other
  # dependencies and no callbacks
  has_many :asset_company_notes, :dependent => :delete_all
  has_one :addr_latlng, :dependent => :destroy

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
  validates_acceptance_of :agree,
    :message => "- Please accept the terms of agreement to proceed"


  attr_accessor :password_confirmation
  attr_accessor :terms
  attr_accessor :agree
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
    self.zipcodes.destroy_all
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

  def set_latlng!
    if ! self.physical_address1.blank? && ! self.physical_address_city.blank? && ! self.physical_address_state.blank? && ! self.physical_address_zip.blank? 
      phys_addr = Geokit::Geocoders::YahooGeocoder.geocode self.physical_address1 + "," + 
        self.physical_address_city + "," + self.physical_address_state + " " + self.physical_address_zip
      if phys_addr && ! phys_addr.lat.blank? && ! phys_addr.lng.blank? 
        latlng = AddrLatlng.new(:agent_id => self.id, :lat => phys_addr.lat, :lng => phys_addr.lng)
        self.addr_latlng = latlng
        self.save
      end
    else
      if ! self.addr_latlng.blank?
        self.addr_latlng.destroy
      end
    end
  end

  def latlng_good?
    self.addr_latlng && self.addr_latlng.lat && self.addr_latlng.lng
  end

  def member_status_text
    if self.member_status == 0
      "free"
    elsif self.member_status == 1
      "basic"
    elsif self.member_status == 2
      "premium"
    end
  end

  def fill_terms_of_agreement
    self.terms = <<"terms"
I have read and agree with the terms and conditions

Last updated: January 18, 2011

1. Your relationship with REO Agents Connect.

1.1 Use of the Service is Subject to these Terms. Your use of any of the REO Agents Connect the "Service") is subject to the terms of a legal agreement between you and REO Agents Connect Inc., whose principal place of business is at 1111 Street, City, State 11111, United States ("REO Agents Connect"). This legal agreement is referred to as the "Terms".

1.2 The Terms include REO Agents Connect's Legal Notices and Privacy Policy. 

(a) Unless otherwise agreed in writing with REO Agents Connect, the Terms will include the 
following: 
(i) the terms and conditions set forth in this document;
(ii) the Legal Notices; and
(iii) the Privacy Policy.

(b) Before you use the service, you should read each of the documents comprising the Terms, and print or save a local copy for your records.

1.3 Changes to the Terms. REO Agents Connect reserves the right to make changes to the Terms from time to time. When these changes are made, REO Agents Connect will make a new copy of the Terms available at http://reoagentsconnect.com/terms_of_agreement. You understand and agree that if you use the Service after the date on which the Terms have changed, REO Agents Connect will treat your use as acceptance of the updated Terms. If a modification is unacceptable to you, you may terminate the agreement by ceasing use of the REO Agents Connect service.  
2. Accepting the Terms.

2.1 Clicking to Accept or Using the REO Agents Connect Service. In order to use the REO Agents Connect Service you must agree to the Terms. You can accept the Terms by:

(a) clicking to accept or agree to the Terms, where this option is made available to you by REO Agents Connect in the user interface for the Service; or
(b) using the REO Agents Connect Service. In this case, you understand and agree that REO Agents Connect will treat your use of the REO Agents Connect Service as acceptance of the Terms from that point onwards.

2.2 U.S. Law Restrictions. You may not use the REO Agents Connect Service and may not accept the Terms if you are a person barred from using the Service under the laws of the United States.

2.3 Authority to Accept the Terms. You represent that you have full power, capacity and authority to accept these Terms. If you are accepting on behalf of your employer or another entity, you represent that you have full legal authority to bind your employer or such entity to these Terms. If you don't have the legal authority to bind, please ensure that an authorized person from your entity consents to and accepts these Terms.

3. Privacy and Personal Information.

3.1 REO Agents Connect's Privacy Policy. For information about REO Agents Connect's data protection practices, please read REO Agents Connect's privacy policy at http://REOAgentsConnect.com/privacy.html. This policy explains how REO Agents Connect treats your personal information and protects your privacy when you use the Service.  
3.2 Use of Your Data under REO Agents Connect's Privacy Policy. You agree to the use of your data in accordance with REO Agents Connect's privacy policy.

3.3 Your Privacy Policy. You must post and abide by an appropriate privacy policy, and will comply with all applicable laws relating to the collection of information from visitors to Your REO Agents Connect Implementation.  
4. Provision of Service by REO Agents Connect.

4.1 Limits on Your Use of the Service. You acknowledge and agree that REO Agents Connect may impose or adjust the limit on the number of transactions you may send or receive through the Service; such fixed upper limits may be set by REO Agents Connect at any time, at REO Agents Connect's discretion.

4.2 Changes to the Service: Termination of the Service.

(b) REO Agents Connect reserves the right in its discretion to cease providing all or any part of the Deprecated Version of the Service immediately without any notice if: 
(i) you have breached any provision of the Terms (or have acted in manner that clearly shows that you do not intend to, or are unable to comply with the provisions of the Terms); or 

(ii) REO Agents Connect is required to do so by law (for example, due to a change to the law governing the provision of the Deprecated Version of the Service); or 

(iii) the Deprecated Version of the Service relies on data or services provided by a third party partner and the relationship with such partner (x) has expired or been terminated or (y) requires REO Agents Connect to change the way REO Agents Connect provides the data or services through the Deprecated Version of the Service; or 

(iv) providing the Deprecated Version of the Service could create a substantial economic burden as determined by REO Agents Connect in its reasonable good faith judgment; or 

(v) providing the Deprecated Version of the Service could create a security risk or material technical burden as determined by REO Agents Connect in its reasonable good faith judgment. 

5. Your REO Agents Connect Account.

5.1 Signing Up for a REO Agents Connect Account. In order to access the Service, you must have a REO Agents Connect Account. You agree that any information you give to REO Agents Connect in connection with your REO Agents Connect Account or your continued use of the Service will always be accurate, correct and up to date.

5.3 Your Passwords and Account Security. You agree that you will be solely responsible to REO Agents Connect for your use of the Service. If you become aware of any unauthorized use of your password, your account, or your key, you agree to notify REO Agents Connect immediately. 

6. REO Agents Connect's Proprietary Rights. You acknowledge and agree that REO Agents Connect (or REO Agents Connect's licensors and their suppliers, as applicable) own all legal right, title and interest in and to the Service and Content, including any intellectual property rights that subsist in the Service and Content (whether those rights happen to be registered or not, and wherever in the world those rights may exist).

7. LIMITATION OF LIABILITY.

8. SUBJECT TO SECTION 13.1, YOU EXPRESSLY UNDERSTAND AND AGREE THAT REO Agents Connect, ITS SUBSIDIARIES AND AFFILIATES, AND REO Agents Connect.S LICENSORS AND THEIR SUPPLIERS, WILL NOT BE LIABLE TO YOU FOR:

(a) ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL OR EXEMPLARY DAMAGES THAT MAY BE INCURRED BY YOU, HOWEVER CAUSED AND UNDER ANY THEORY OF LIABILITY (INCLUDING, BUT NOT BE LIMITED TO, ANY LOSS OF PROFIT (WHETHER INCURRED DIRECTLY OR INDIRECTLY), ANY LOSS OF GOODWILL OR BUSINESS REPUTATION, ANY LOSS OF DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, OR OTHER INTANGIBLE LOSS); OR

(b) ANY LOSS OR DAMAGE AS A RESULT OF:
(i) ANY RELIANCE PLACED BY YOU ON THE COMPLETENESS, ACCURACY OR EXISTENCE OF ANY ADVERTISING, OR AS A RESULT OF ANY RELATIONSHIP OR TRANSACTION BETWEEN YOU AND ANY ADVERTISER OR SPONSOR WHOSE ADVERTISING APPEARS ON THE REO Agents Connect SERVICES;
(ii) ANY CHANGES THAT REO Agents Connect MAY MAKE TO THE SERVICE, OR ANY PERMANENT OR TEMPORARY CESSATION IN THE PROVISION OF THE SERVICE (OR ANY FEATURES WITHIN THE SERVICE);
(iii) THE DELETION OF, CORRUPTION OF, OR FAILURE TO STORE, ANY CONTENT AND OTHER COMMUNICATIONS DATA MAINTAINED OR TRANSMITTED BY OR THROUGH YOUR USE OF THE SERVICE;
(iv) YOUR FAILURE TO PROVIDE REO Agents Connect WITH ACCURATE ACCOUNT INFORMATION; OR
(v) YOUR FAILURE TO KEEP YOUR PASSWORD OR ACCOUNT DETAILS SECURE AND CONFIDENTIAL.

9. THE LIMITATIONS ON REO Agents Connect'S LIABILITY TO YOU IN SECTION 14.1 ABOVE WILL APPLY WHETHER OR NOT REO Agents Connect, ITS SUBSIDIARIES, AFFILIATES, LICENSORS OR THEIR SUPPLIERS HAVE BEEN ADVISED OF OR SHOULD HAVE BEEN AWARE OF THE POSSIBILITY OF ANY SUCH LOSSES OR DAMAGES.

10. The Service may include hyperlinks to other websites or content or resources.  REO Agents Connect has no control over any web sites or resources that are provided by companies or persons other than REO Agents Connect. You acknowledge and agree that REO Agents Connect is not responsible for the availability of any such external sites or resources, and does not endorse any advertising, products or other materials on or available from such websites or resources.

10.1 You acknowledge and agree that REO Agents Connect is not liable for any loss or damage that may be incurred by you as a result of the availability of those external sites or resources, or as a result of any reliance placed by you on the completeness, accuracy or existence of any advertising, products, or other materials on, or available from, such websites or resources.

11. General Legal Terms.

11.1 Notices. You agree that REO Agents Connect may provide you with notices, including those regarding changes to the Terms, by email, regular mail, or postings on the Service.

11.2 No Waiver. You agree that if REO Agents Connect does not exercise or enforce any legal right or remedy contained in the Terms (or that REO Agents Connect has the benefit of under any applicable law), this will not be taken to be a formal waiver of REO Agents Connect's rights and that those rights or remedies will still be available to REO Agents Connect. Any waiver of any provision of these Terms will be effective only if REO Agents Connect expressly states in a signed writing that it is waiving a specified Term.

11.3 Severability. If any court of law that has jurisdiction rules that any provision of these Terms is invalid, then that provision will be removed from the Terms without affecting the rest of the Terms. The remaining provisions of the Terms will continue to be valid and enforceable.

11.5 Assignment. The Terms may be assigned by REO Agents Connect and will inure to the benefit of REO Agents Connect, its successors and assigns.

11.6 Governing Law and Jurisdiction; Injunctive Relief. The Terms, and your relationship with REO Agents Connect under the Terms, will be governed by the laws of the State of California, USA, without regard to its conflict of laws provisions. You and REO Agents Connect agree to submit to the exclusive jurisdiction of the courts located in the County of Santa Clara, California, USA, to resolve any legal matter arising from the Terms.  Notwithstanding this, you agree that REO Agents Connect will be allowed to apply for injunctive remedies (or an equivalent type of urgent legal relief) in any jurisdiction.

11.7 Complete Agreement. The Terms constitute the whole legal agreement between you and REO Agents Connect and govern your use of the Service and Content, and completely replace and supersede any prior agreements between you and REO Agents Connect, written or oral, in relation to the Service and Content.
    
terms

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
