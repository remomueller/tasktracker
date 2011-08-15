module OmniAuth
  module Strategies
    class LDAP
      
      def initialize(app, options = {}, &block)
        super(app, options[:name] || :ldap, options.dup, &block)
        @name_proc = (@options.delete(:name_proc) || Proc.new {|name| name})
        @adaptor = OmniAuth::Strategies::LDAP::Adaptor.new(options)
        @domain = options[:domain] # Added
      end
      
      protected
      
      # Reroutes directly to callback_phase instead of redirecting to callback_path
      # TODO: Possibility that this could be removed in the future.
      def request_phase
        Rails.logger.info "Request Phase Hook"
        if env['REQUEST_METHOD'] == 'GET'
          get_credentials
        else
          session['omniauth.ldap'] = {'username' => request['username'], 'password' => request['password']}
          if true
            Rails.logger.info "Skipping Redirect"
            callback_phase # Added
          else
            redirect callback_path
          end
        end
      end
      
      # Includes addition of a "domain"
      def callback_phase
        begin
          creds = session['omniauth.ldap']
          session.delete 'omniauth.ldap'
          @ldap_user_info = {}
          begin
            creds['username'] = @domain.to_s + '\\' + creds['username'] unless @domain.blank?
            @adaptor.bind(:bind_dn => creds['username'], :password => creds['password'])
          rescue Exception => e
            Rails.logger.info "Exception #{e.inspect}"
            Rails.logger.info "failed to bind with the default credentials: " + e.message
            return fail!(:invalid_credentials, e)
          end
          
          @ldap_user_info = @adaptor.search(:base => @adaptor.base, :filter => Net::LDAP::Filter.eq(@adaptor.uid, creds['username'].split('\\').last.to_s),:limit => 1)
          @ldap_user_info.each do |key, val|
            @ldap_user_info[key] = val.first if val.class == Array and val.size == 1
          end
          
          @user_info = self.class.map_user(@@config, @ldap_user_info)

          @env['REQUEST_METHOD'] = 'GET'
          # @env['PATH_INFO'] = callback_path
          @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix.split('/').last}/#{name}/callback"
          
          @env['omniauth.auth'] = {'provider' => 'ldap', 'uid' => @user_info['uid'], 'user_info' => @user_info, 'bla' => 5}
        rescue Exception => e
          Rails.logger.info "Exception #{e.inspect}"
          return fail!(:invalid_credentials, e)
        end
        
        call_app!
      end
      
      def self.map_user mapper, object
        user = {}
        mapper.each do |key, value|
          case value
            when String
              if object[value.downcase.to_sym]
                if object[value.downcase.to_sym].kind_of?(Array)
                  user[key] = object[value.downcase.to_sym].join(', ')
                else
                  user[key] = object[value.downcase.to_sym].to_s 
                end
              end
            when Array
              # value.each {|v| (user[key] = object[v.downcase.to_sym].to_s; break;) if object[v.downcase.to_sym]}
              value.each {|v| (user[key] = object[v.downcase.to_sym].join(', '); break;) if object[v.downcase.to_sym]}
            when Hash
              value.map do |key1, value1|
                pattern = key1.dup
                value1.each_with_index do |v,i|
                  part = '';
                  v.each {|v1| (part = object[v1.downcase.to_sym].to_s; break;) if object[v1.downcase.to_sym]}
                  pattern.gsub!("%#{i}",part||'') 
                end 
                user[key] = pattern
              end
            end
          end
        user
      end
      
    end
  end
end