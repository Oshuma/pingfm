require 'yaml'

module Pingfm

  class KeyloadingError < Exception; end

  # Manages the YAML file containing the keys.
  # TODO: This is kinda dumb and should probably just be Pingfm.config[] or some shit.
  # TODO: Encryption might be nice; might be overkill.
  class Keyloader

    CONFIG_PATH = (RUBY_PLATFORM =~ /mswin32/ ? ENV['HOMEPATH'] : ENV['HOME'])
    CONFIG_FILE = '.pingfm.yml'

    # Path to YAML file containing keys.
    attr_accessor :key_file

    # Ping.fm uses this as the key for user authentication.
    attr_accessor :app_key

    def initialize(key_file = File.expand_path(File.join(CONFIG_PATH, CONFIG_FILE)))
      @key_file = key_file

      # Load keys on init.
      load_keys!
    end

    # Load a new set of keys from <tt>new_key_file</tt>.
    def load_keys(new_key_file)
      if File.exist?(new_key_file) and File.readable?(new_key_file)
        data = ::YAML::load_file(new_key_file)
        @key_file = new_key_file if @key_file.nil?
        @app_key  = data['app_key']
      else
        raise KeyloadingError, "Key file '#{new_key_file}' not found."
      end
    end

    # Load keys using the known key_file.
    def load_keys!
      load_keys(@key_file)
    end

    # Returns true if app_key has been loaded successfully.
    def has_keys?
      return true unless @app_key.nil?
      return false
    end

    # Save key data to key_file.
    def save
      File.open( @key_file, 'w+' ) do |out|
        ::YAML::dump( {'app_key' => @app_key}, out )
      end
    end
  end
end
