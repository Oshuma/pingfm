require 'spec_helper'
require 'tempfile'

describe Pingfm::Keyloader do

  before(:each) do
    # TODO: This could be cleaned up a bit.
    @key_data = {'app_key' => 'bar'}
    @tf = Tempfile.new('keys.yml')
    ::YAML::dump(@key_data, @tf)
    @tmp_path = @tf.path
    @tf.close
  end

  after(:each) do
    @tf.unlink
  end

  it "should use keys from yaml file if found" do
    loader = Pingfm::Keyloader.new(@tmp_path)
    loader.has_keys?.should be_true
    loader.key_file.should eql(@tmp_path)
    loader.app_key.should eql(@key_data['app_key'])
  end

  it "should save keys to key_file" do
    loader = Pingfm::Keyloader.new(@tmp_path)
    loader.app_key = 'baz'
    loader.save

    loader.has_keys?.should be_true
    File.exist?(loader.key_file).should be_true
    File.readable?(loader.key_file).should be_true
    YAML::load_file(loader.key_file)['app_key'].should eql('baz')
  end

  it "should raise KeyloadingError if key_file doesn't exist" do
    lambda do
      Pingfm::Keyloader.new("/tmp/DOES_NOT_EXIST-#{Time.now.to_i}")
    end.should raise_error(Pingfm::KeyloadingError)
  end
end
