module Pingfm
  class ConfigNotFound < Exception; end

  class Config
    CONFIG_PATH = (RUBY_PLATFORM =~ /mswin32/ ? ENV['HOMEPATH'] : ENV['HOME'])
    CONFIG_FILE = File.expand_path(File.join(CONFIG_PATH, '.pingfm.yml'))

    class << self

      # Prompts the user for their API key and saves it.
      def ask_for_app_key!
        STDOUT.print 'Enter your Ping.fm User API key (http://ping.fm/key/): '
        @@config ||= {}
        @@config['app_key'] = STDIN.gets.chomp
        save!
      end

      def [](key)
        setup! unless defined?(@@config)
        @@config[key]
      end

      def save!
        ::File.open(CONFIG_FILE, 'w') do |config_file|
          ::YAML.dump(@@config, config_file)
        end
      end

      def setup!(config_file = CONFIG_FILE)
        raise Pingfm::ConfigNotFound unless File.exists?(config_file)
        @@config = ::YAML.load_file(config_file)
      end

    end
  end
end
