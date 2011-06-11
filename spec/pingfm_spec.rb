require 'spec_helper'

describe Pingfm do
  it 'should return the version string' do
    Pingfm::VERSION.should be_a_kind_of(String)
  end
end
