require 'digest/sha1'

class AssetCompany < ActiveRecord::Base
  has_many :asset_company_notes

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_confirmation_of :password
  validate :password_non_blank

  attr_accessor :password_confirmation

  def self.authenticate(email, password)
    contact = self.find_by_email(email)
    if contact
      # the salt and hashed_password is blank if the account exist but not yet verified
      if contact.salt.blank? || contact.hashed_password.blank?
        contact = nil
      else
        expected_password = encrypted_password(password, contact.salt)
        if contact.hashed_password != expected_password
          contact = nil
        end
      end
    end
    contact
  end

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = AssetCompany.encrypted_password(self.password, self.salt)
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

end
