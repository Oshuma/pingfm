require 'yaml'

module Pingfm
  
  class KeyloadingError < Exception; end
  
  # manages the YAML file containing the keys - encryption might be nice, might be overkill
  class Keyloader
    
    # Path to YAML file containing keys
    attr_accessor :keyfile
    
    # ping.fm uses this as the key for the registered application
    attr_accessor :api_key
    
    # ping.fm uses this as the key for the user
    attr_accessor :app_key
    
    def initialize(keyfile = File.expand_path('~/.pingfm_keys.yml'))
      @keyfile = keyfile
      
      # load keys on init
      load_keys!
    end
    
    # load a new set of keys
    def load_keys(keyfile)
      if File.exist?(keyfile) and File.readable?(keyfile)
        data = YAML::load_file(keyfile)
        @keyfile = keyfile if @keyfile.nil?
        @api_key = data['api_key']
        @app_key = data['app_key']
      end
    end
    
    # load keys using the known keyfile
    def load_keys!
      load_keys(@keyfile)
    end
    
    # if keys have been loaded successfully
    def has_keys?
      return true unless @api_key.nil? or @app_key.nil?
      return false
    end
    
    # save key data to keyfile
    def save
      File.open( @keyfile, 'w+' ) do |out|
        YAML::dump( {'api_key' => @api_key, 'app_key' => @app_key}, out )
      end
    end
  end
end