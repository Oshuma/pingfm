# $Id$

require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Pingfm::Client, " with expected results" do
  
  before(:each) do
    @client = Pingfm::Client.new('a','b')
  end
  
  it "should validate keys successfully" do
    # mock the http call
    #Net::HTTP.should_receive(:post_form).with("#{Pingfm::API_URL}/user.validate",params).and_return(response)
    
  end
  
  it "should list the user's services properly" do
    
  end
  
  it "should list the user's custom triggers" do
    
  end
  
  it "should list the user's recent posts" do
    
  end
  
  it "should post a message to the service" do
    
  end
  
end

# EOF
