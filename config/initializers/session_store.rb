# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_reo_session',
  :secret      => 'e51fa5a4be651369dee808c5326d90cee096092c982824134afef744315f4c2158b2e79703dff5969cd3b7cfb3df2589a6bf32afd5db4d3f614d75c72e6e331e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
