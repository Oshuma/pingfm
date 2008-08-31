require File.join(File.dirname(__FILE__), %w[spec_helper])
require 'tempfile'

describe Pingfm::Keyloader do

  before(:each) do
    @keydata = {'api_key' => 'foo', 'app_key' => 'bar'}
    @tf = Tempfile.new('keys.yml')
    YAML::dump(@keydata, @tf)
    @tmp_path = @tf.path
    @tf.close
  end

  after(:each) do
    @tf.unlink
  end

  it "should use keys from yaml file if found" do
    loader = Pingfm::Keyloader.new(@tmp_path)
    loader.has_keys?.should be_true
    loader.keyfile.should eql(@tmp_path)
    loader.api_key.should eql(@keydata['api_key'])
    loader.app_key.should eql(@keydata['app_key'])
  end

  it "should save keys to keyfile" do
    loader = Pingfm::Keyloader.new(@tmp_path)
    loader.app_key = 'baz'
    loader.save

    loader.has_keys?.should be_true
    File.exist?(loader.keyfile).should be_true
    File.readable?(loader.keyfile).should be_true
    YAML::load_file(loader.keyfile)['app_key'].should eql('baz')
  end

  it "should behave if keys cannot be loaded" do
    loader = Pingfm::Keyloader.new('/tmp/nofile')
    loader.has_keys?.should be_false
    loader.api_key.should be_nil
    loader.app_key.should be_nil
  end
end