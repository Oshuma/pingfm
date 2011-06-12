require 'spec_helper'

describe Pingfm::Config do

  SPEC_CONFIG_FILE = "#{File.dirname(__FILE__)}/../pingfm_spec.yml"

  it 'has a CONFIG_PATH' do
    Pingfm::Config::CONFIG_PATH.should_not be_nil
  end

  it 'has a CONFIG_FILE' do
    Pingfm::Config::CONFIG_FILE.should_not be_nil
  end

  it 'loads the given config file' do
    Pingfm::Config.setup!(SPEC_CONFIG_FILE)
    @config = ::YAML.load_file(SPEC_CONFIG_FILE)
    Pingfm::Config['app_key'].should == @config['app_key']
  end

end
