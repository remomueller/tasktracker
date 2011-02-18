module OmniAuth
  module Strategies
    class LDAP
      def perform
        # Rails.logger.debug "PERFORM! #{request.POST.inspect} #{@adaptor.inspect}"
        begin
          begin
            @adaptor.bind(:bind_dn => request.POST['username'], :password => request.POST['password'])
          rescue Exception => e
            Rails.logger.info "failed to bind with the default credentials: " + e.message
            return fail!(:invalid_credentials, e)
          end
          
          @ldap_user_info = @adaptor.search(:base => @adaptor.base, :filter => Net::LDAP::Filter.eq(@adaptor.uid, request.POST['username'].split('\\').last.to_s),:limit => 1)
          Rails.logger.debug "LDAP USER INFO #{@ldap_user_info.inspect}"
          @user_info = self.class.map_user(@@config, @ldap_user_info)
          Rails.logger.debug "USER INFO #{@user_info.inspect}"
          @env['REQUEST_METHOD'] = 'GET'
          @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix.split('/').last}/#{name}/callback"
          @env['omniauth.auth'] = {'provider' => 'ldap', 'uid' => @user_info['uid'], 'user_info' => @user_info}
          Rails.logger.debug "ENV: " + @env.inspect

        rescue Exception => e
          Rails.logger.info "Exception #{e.inspect}"
          return fail!(:invalid_credentials, e)
        end         
        
        call_app!
      end
    end
  end
end

module OmniAuth
  module Strategies
    # OmniAuth strategy for connecting via OpenID. This allows for connection
    # to a wide variety of sites, some of which are listed [on the OpenID website](http://openid.net/get-an-openid/).
    class OpenID
      
      def dummy_app
        Rails.logger.debug "dummy_app id #{identifier} return_to #{callback_url}"
        lambda{|env| [401, {"WWW-Authenticate" => Rack::OpenID.build_header(
          :identifier => identifier,
          :trust_root => SITE_URL,
          :return_to => callback_url,
          :required => @options[:required],
          :optional => @options[:optional],
          :method => 'post'
        )}, []]}
      end
      
      def callback_phase
        env['REQUEST_METHOD'] = 'GET'
        openid = Rack::OpenID.new(lambda{|env| [200,{},[]]}, @store)
        Rails.logger.info "OPENID: #{openid.inspect}"
        openid.call(env)
        Rails.logger.info "OPENID RESPONSE: #{env['rack.openid.response']}"
        @openid_response = env.delete('rack.openid.response')
        if @openid_response && @openid_response.status == :success
          super
        else
          fail!(:invalid_credentials)
        end
      end
      
      
      # def start
      #   openid = Rack::OpenID.new(dummy_app, @store)
      #   Rails.logger.info "START: " + openid.inspect
      #   # One of these needs to be set to SITE_URL  SITE_URL.gsub('http://', '').gsub('https://', '').split('/').first
      #   
      #   Rails.logger.info "HTTP_REFERER: " + env['HTTP_REFERER']
      #   Rails.logger.info "SERVER_NAME: " + env['SERVER_NAME']
      #   Rails.logger.info "HTTP_HOST: " + env['HTTP_HOST']
      #   
      #   # env['HTTP_REFERER'] = SITE_URL.gsub('http://', '').gsub('https://', '').split('/').first
      #   # env['SERVER_NAME'] = SITE_URL.gsub('http://', '').gsub('https://', '').split('/').first
      #   # env['HTTP_HOST'] = SITE_URL.gsub('http://', '').gsub('https://', '').split('/').first
      #   
      #   Rails.logger.info "HTTP_REFERER: " + env['HTTP_REFERER']
      #   Rails.logger.info "SERVER_NAME: " + env['SERVER_NAME']
      #   Rails.logger.info "HTTP_HOST: " + env['HTTP_HOST']
      # 
      #   response = openid.call(env)
      #   case env['rack.openid.response']
      #   when Rack::OpenID::MissingResponse, Rack::OpenID::TimeoutResponse
      #     fail!(:connection_failed)
      #   else
      #     response
      #   end
      # end
      
      def callback_url
        uri = URI.parse(request.url)
        uri.path += '/callback'
        # Rails.logger.debug "#{SITE_URL}"
        # Rails.logger.debug "CALLBACK_URL: #{uri.to_s}"
        # Rails.logger.debug "CALLBACK_URL: #{uri.to_s.split('/auth').last}"
        # Rails.logger.debug "MODIFIED: #{SITE_URL} /auth #{uri.to_s.split('/auth').last}"
        uri.to_s
        "#{SITE_URL}/auth#{uri.to_s.split('/auth').last}"
      end
    end
  end
end

module OmniAuth
  
  module Strategy
    
    def full_host
      uri = URI.parse(request.url)
      uri.path = ''
      uri.query = nil
      uri.to_s
      Rails.logger.info "FULL_HOST: #{SITE_URL}"
      SITE_URL
    end
    
    def callback_url
      full_host + "#{OmniAuth.config.path_prefix}/#{name}/callback"
    end
  end
end

# module OmniAuth
#   module Strategies
#     class LDAP
#       include OmniAuth::Strategy
#       
#       autoload :Adaptor, 'omniauth/strategies/ldap/adaptor'
#       @@config   =  {'name' => 'cn', 'first_name' => 'givenName', 'last_name' => 'sn', 'email' => ['mail', "email", 'userPrincipalName'],
#                     'phone' => ['telephoneNumber', 'homePhone', 'facsimileTelephoneNumber'],
#                     'mobile_number' => ['mobile', 'mobileTelephoneNumber'],
#                     'nickname' => ['uid', 'userid', 'sAMAccountName'],
#                     'title' => 'title',
#                     'location' => {"%0, %1, %2, %3 %4" => [['address', 'postalAddress', 'homePostalAddress', 'street', 'streetAddress'], ['l'], ['st'],['co'],['postOfficeBox']]},
#                     'uid' => 'dn',
#                     'url' => ['wwwhomepage'],
#                     'image' => 'jpegPhoto',
#                     'description' => 'description'}
#       def initialize(app, title, options = {})
#         super(app, options.delete(:name) || :ldap)
#         @title = title
#         @adaptor = OmniAuth::Strategies::LDAP::Adaptor.new(options)
#       end
#       
#       protected
#       
#       def request_phase
#         if env['REQUEST_METHOD'] == 'GET'
#           get_credentials
#         else
#           perform
#         end
#       end
# 
#       def get_credentials
#         OmniAuth::Form.build(@title) do
#           text_field 'Login', 'username'
#           password_field 'Password', 'password'
#         end.to_response
#       end
#       def perform
#         Rails.logger.debug "PERFORM! #{request.POST.inspect} #{@adaptor.inspect}"
#         # begin
#           @adaptor.bind(:bind_dn => request.POST['username'], :password => request.POST['password'])
#           Rails.logger.debug "Gets here"
#           @ldap_user_info = @adaptor.search(:filter => Net::LDAP::Filter.eq(@adaptor.uid, request.POST['username']),:limit => 1)
#           Rails.logger.debug "LDAP USER INFO #{@ldap_user_info.inspect}"
#           @user_info = self.class.map_user(@@config, @ldap_user_info)
#           Rails.logger.debug "USER INFO #{@user_info.inspect}"
#           @env['REQUEST_METHOD'] = 'GET'
#           @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix}/#{name}/callback"
#           @env['omniauth.auth'] = {'provider' => 'ldap', 'uid' => request.POST['username'], 'user_info' => {'email' => request.POST['username'].split('\\').last.to_s + "@partners.org"}}
#           
#           call_app!
#         # rescue Exception => e
#         #   Rails.logger.debug "Exception #{e.inspect}"
#         #   fail!(:invalid_credentials, e)
#         # end
#       end      
# 
#       def callback_phase
#         fail!(:invalid_request)
#       end
#       
#       def auth_hash
#         OmniAuth::Utils.deep_merge(super, {
#           'uid' => @user_info["uid"],
#           'user_info' => @user_info,
#           'extra' => @ldap_user_info
#         })
#       end
#       
#       def self.map_user mapper, object
#         user = {}
#         mapper.each do |key, value|
#           case value
#             when String
#               user[key] = object[value.downcase.to_sym].to_s if object[value.downcase.to_sym]
#             when Array
#               value.each {|v| (user[key] = object[v.downcase.to_sym].to_s; break;) if object[v.downcase.to_sym]}
#             when Hash
#               value.map do |key1, value1|
#                 pattern = key1.dup
#                 value1.each_with_index do |v,i|
#                   part = '';
#                   v.each {|v1| (part = object[v1.downcase.to_sym].to_s; break;) if object[v1.downcase.to_sym]}
#                   pattern.gsub!("%#{i}",part||'') 
#                 end 
#                 user[key] = pattern
#               end
#             end
#           end
#         user
#       end       
#     end
#   end
# end
# 
# 
# #this code boughts pieces from activeldap and net-ldap
# require 'rack'
# require 'net/ldap'
# require 'net/ntlm'
# require 'uri'
# module OmniAuth
#   module Strategies
#     class LDAP
#       class Adaptor
#         class LdapError < StandardError; end
#         class ConfigurationError < StandardError; end
#         class AuthenticationError < StandardError; end
#         class ConnectionError < StandardError; end
#         VALID_ADAPTER_CONFIGURATION_KEYS = [:host, :port, :method, :bind_dn, :password,
#                                             :try_sasl, :sasl_mechanisms, :uid, :base]
#         MUST_HAVE_KEYS = [:host, :port, :method, :uid, :base]
#         METHOD = {
#           :ssl => :simple_tls,
#           :tls => :start_tls,
#           :plain => nil
#         }     
#         attr_accessor :bind_dn, :password                                     
#         attr_reader :connection, :uid, :base
#         def initialize(configuration={})
#           @connection = nil
#           @disconnected = false
#           @bound = false
#           @configuration = configuration.dup
#           @logger = @configuration.delete(:logger)
#           message = []
#           MUST_HAVE_KEYS.each do |name|
#             message << name if configuration[name].nil? 
#           end
#           raise ArgumentError.new(message.join(",") +" MUST be provided") unless message.empty?
#           VALID_ADAPTER_CONFIGURATION_KEYS.each do |name|
#             instance_variable_set("@#{name}", configuration[name])
#           end
#         end
#   
#         def connect(options={})
#           host = options[:host] || @host
#           method = options[:method] || @method || :plain
#           port = options[:port] || @port || ensure_port(method)
#           method = ensure_method(method)
#           @disconnected = false
#           @bound = false
#           @bind_tried = false       
#           config = {
#             :host => host,
#             :port => port,
#           }
#           config[:encryption] = {:method => method} if method
#           @connection, @uri, @with_start_tls = 
#           begin
#             uri = construct_uri(host, port, method == :simple_tls)
#             Rails.logger.debug uri
#             with_start_tls = method == :start_tls
#             puts ({:uri => uri, :with_start_tls => with_start_tls}).inspect
#             Rails.logger.debug "CONFIG: " + config.inspect
#             [Net::LDAP::Connection.new(config), uri, with_start_tls]
#           rescue Net::LDAP::LdapError
#             raise ConnectionError, $!.message
#           end
#         end
#   
#         def unbind(options={})
#             @connection.close # Net::LDAP doesn't implement unbind.
#         end
#   
#         def bind(options={})
#           connect(options) unless connecting?
#           begin
#             @bind_tried = true
#     
#             bind_dn = (options[:bind_dn] || @bind_dn).to_s
#             try_sasl = options.has_key?(:try_sasl) ? options[:try_sasl] : @try_sasl
#     
#             # Rough bind loop:
#             # Attempt 1: SASL if available
#             # Attempt 2: SIMPLE with credentials if password block
#             if try_sasl and sasl_bind(bind_dn, options)
#               Rails.logger.debug "bind with sasl"
#             elsif simple_bind(bind_dn, options)
#               Rails.logger.debug "bind with simple"
#             else
#               message = yield if block_given?
#               message ||= ('All authentication methods for %s exhausted.') % target
#               raise AuthenticationError, message
#             end
#     
#             @bound = true
#           rescue Net::LDAP::LdapError
#             raise AuthenticationError, $!.message
#           end
#         end
#   
#         def disconnect!(options={})
#           unbind(options)
#           @connection = @uri = @with_start_tls = nil
#           @disconnected = true
#         end
#   
#         def rebind(options={})
#           unbind(options) if bound?
#           connect(options)
#         end
#   
#         def connecting?
#           !@connection.nil? and !@disconnected
#         end
#   
#         def bound?
#           connecting? and @bound
#         end
#         
#         def search(options={}, &block)
#           base = options[:base]
#           filter = options[:filter]
#           limit = options[:limit]
#   
#           args = {
#             :base => @base,
#             :filter => filter,
#             :size => limit
#           }
#           puts args.inspect
#           attributes = {}
#           execute(:search, args) do |entry|
#             entry.attribute_names.each do |name|
#               attributes[name] = entry[name]
#             end
#           end
#           attributes
#       end
#         private
#         def execute(method, *args, &block)
#           Rails.logger.debug @connection.inspect
#           Rails.logger.debug args.inspect
#           result = @connection.send(method, *args, &block)
#           message = nil
#           if result.is_a?(Hash)
#             message = result[:errorMessage]
#             result = result[:resultCode]
#           end
#           unless result.zero?
#             message = [Net::LDAP.result2string(result), message].compact.join(": ")
#             Rails.logger.debug message
#             raise LdapError, message
#           end
#         end       
#         
#         def ensure_port(method)
#           if method == :ssl
#             URI::LDAPS::DEFAULT_PORT
#           else
#             URI::LDAP::DEFAULT_PORT
#           end
#         end
#   
#         def prepare_connection(options)
#         end
#   
#         def ensure_method(method)
#           method ||= "plain"
#           normalized_method = method.to_s.downcase.to_sym
#           return METHOD[normalized_method] if METHOD.has_key?(normalized_method)
#   
#           available_methods = METHOD.keys.collect {|m| m.inspect}.join(", ")
#           format = "%s is not one of the available connect methods: %s"
#           raise ConfigurationError, format % [method.inspect, available_methods]
#         end
#         
#         def sasl_bind(bind_dn, options={})
#           sasl_mechanisms = options[:sasl_mechanisms] || @sasl_mechanisms
#             sasl_mechanisms.each do |mechanism|
#               begin
#                 normalized_mechanism = mechanism.downcase.gsub(/-/, '_')
#                 sasl_bind_setup = "sasl_bind_setup_#{normalized_mechanism}"
#                 next unless respond_to?(sasl_bind_setup, true)
#                 initial_credential, challenge_response =
#                   send(sasl_bind_setup, bind_dn, options)
#                 args = {
#                   :method => :sasl,
#                   :initial_credential => initial_credential,
#                   :mechanism => mechanism,
#                   :challenge_response => challenge_response,
#                 }
#                 info = {
#                   :name => "bind: SASL", :dn => bind_dn, :mechanism => mechanism,
#                 }
#                 puts info.inspect
#                 execute(:bind, args)
#                 return true
#               rescue Exception => e
#                 puts e.message
#               end
#             end
#           false
#         end
#  
#       def sasl_bind_setup_digest_md5(bind_dn, options)
#         initial_credential = ""
#         challenge_response = Proc.new do |cred|
#           pref = SASL::Preferences.new :digest_uri => "ldap/#{@host}", :username => bind_dn, :has_password? => true, :password => options[:password]||@password
#           sasl = SASL.new("DIGEST-MD5", pref)
#           response = sasl.receive("challenge", cred)
#           response[1]
#         end
#         [initial_credential, challenge_response]
#       end
#       def sasl_bind_setup_gss_spnego(bind_dn, options)
#         puts options.inspect
#         user,psw = [bind_dn, options[:password]||@password]
#         raise LdapError.new( "invalid binding information" ) unless (user && psw)
# 
#         nego = proc {|challenge|
#           t2_msg = Net::NTLM::Message.parse( challenge )
#           user, domain = user.split('\\').reverse
#           t2_msg.target_name = Net::NTLM::encode_utf16le(domain) if domain
#           t3_msg = t2_msg.response( {:user => user, :password => psw}, {:ntlmv2 => true} )
#           t3_msg.serialize
#         }        
#         [Net::NTLM::Message::Type1.new.serialize, nego]        
#       end
#       
#         def simple_bind(bind_dn, options={})
#             args = {
#               :method => :simple,
#               :username => bind_dn,
#               :password => options[:password]||@password,
#             }
#             
#             Rails.logger.debug "args: #{args.inspect}"
#             
#             execute(:bind, args)
#             true
#         end
#         
#         def construct_uri(host, port, ssl)
#           protocol = ssl ? "ldaps" : "ldap"
#           URI.parse("#{protocol}://#{host}:#{port}").to_s
#         end
#   
#         def target
#           return nil if @uri.nil?
#           if @with_start_tls
#             "#{@uri}(StartTLS)"
#           else
#             @uri
#           end
#         end 
#       end
#     end
#   end
# end
