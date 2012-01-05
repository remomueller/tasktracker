require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, OpenID::Store::Filesystem.new('/tmp'), :name => 'google_apps', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :facebook, 'APP_ID', 'APP_SECRET'
  provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
  provider :CAS, :cas_server => 'https://www.example.com/cas'
  provider :LDAP, :host => 'ldap.example.com', :port => 389, :method => :simple, :base => 'cn=users,dc=example,dc=com', :uid => 'sAMAccountName', :try_sasl => true, :sasl_mechanisms => "GSS-SPNEGO", :domain => ''
end

# This list will show the first choice as the default, and the rest as potential secondary login methods.
PROVIDERS = [:google_apps, :twitter, :facebook, :linked_in, :open_id, :CAS, :LDAP]

# LDAP
# :port (required) - The LDAP server port.
# :method (required) - May be :plain, :ssl, or :tls.
# :base (required) - The distinguished name (DN) for your organization; all users should be searchable under this base.
# :uid (required) - The LDAP attribute name for the user name in the login form. Typically AD would be 'sAMAccountName' or 'UniquePersonalIdentifier', while OpenLDAP is 'uid'. You can also use 'dn' for the user to put in the dn in the login form (but usually is too long for user to remember or know).
# :try_sasl - Try to use SASL connection to server.
# :sasl_mechanisms - Mechanisms supported are 'DIGEST-MD5' and 'GSS-SPNEGO'
# :domain - Enter to keep users from having to enter the LDAP domain, usually in the form domain\username. Backslash will be appended automatically.