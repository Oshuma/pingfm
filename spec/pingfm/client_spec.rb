require 'spec_helper'

# TODO: These specs kinda suck.

describe Pingfm::Client do
  it 'should have an API_URL' do
    Pingfm::Client::API_URL.should_not be_nil
  end

  it 'should have an API_KEY' do
    Pingfm::Client::API_KEY.should_not be_nil
  end
end

describe Pingfm::Client, "with expected results" do

  before(:each) do
    @client = Pingfm::Client.new('b')
    @params = {'api_key' => Pingfm::Client::API_KEY, 'user_app_key' => 'b'}
  end

  it "should validate keys successfully" do
    init_ok_response 'user.validate'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.validate
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
  end

  it "should list the user's services properly" do
    init_service_response

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.services
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
    result['services'].should_not be_nil
    result['services'].should_not be_empty
    result['services'].length.should eql(2)
    result['services'].first['id'].should eql('twitter')
  end

  it "should list the system services" do
    init_system_services_response
    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.system_services
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
    result['services'].should_not be_nil
    result['services'].should_not be_empty
    result['services'].length.should eql(2)
    result['services'].first['id'].should eql('bebo')
  end

  it "should list the user's custom triggers" do
    init_trigger_response

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.triggers
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
    result['triggers'].should_not be_nil
    result['triggers'].should_not be_empty
    result['triggers'].length.should eql(2)
    result['triggers'].first['id'].should eql('twt')
  end

  it "should list the user's recent posts" do
    init_latest_response

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"
    @params.merge!('limit'=>5,'order'=>'DESC')

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.latest(5)
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
    result['messages'].should_not be_nil
    result['messages'].should_not be_empty
    result['messages'].length.should eql(3)
    result['messages'].first['id'].should eql('12345')
    result['messages'].last['location'].should_not be_empty
  end

  it "should post a message to the service" do
    init_ok_response 'user.post'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"
    @params.merge!('body' => 'foo', 'title' => '',
    'post_method' => 'default', 'service' => '',
    'debug' => 0)

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.post('foo')
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
  end

  it "should post a message to the service using a trigger" do
    init_ok_response 'user.tpost'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"
    @params.merge!('body' => 'foo', 'title' => '',
    'trigger' => 'twt', 'debug' => 0)

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.tpost('foo','twt')
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
  end

  it "should get the user app key from the mobile_key" do
    init_user_key_response

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"
    @params.merge!('mobile_key' => @mobile_key)

    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    result = @client.user_key(@mobile_key)
    result.should_not be_empty
    result['status'].should_not be_nil
    result['app_key'].should == @app_key
  end

end

describe Pingfm::Client, "with error messages" do

  before(:each) do
    @client = Pingfm::Client.new('b')
    @params = {'api_key' => Pingfm::Client::API_KEY, 'user_app_key' => 'b'}
  end

  it "should handle a failed validate cleanly" do
    init_fail_response 'user.validate'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.validate
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end

  it "should handle a failed system services cleanly" do
    init_fail_response 'system.services'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.system_services
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end

  it "should handle a failed user's services cleanly" do
    init_fail_response 'user.services'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.services
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end

  it "should handle a failed user's triggers cleanly" do
    init_fail_response 'user.triggers'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.triggers
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end

  it "should handle a failed user's latest messages cleanly" do
    init_fail_response 'user.latest'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    @params.merge!('order' => 'DESC', 'limit' => 25)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.latest
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end

  it "should handle a failed user post cleanly" do
    init_fail_response 'user.post'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    @params.merge!({'post_method' => 'default', 'title' => '',
                    'service' => '', 'body' => 'test message', 'debug' => 0})
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.post('test message')
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end

  it "should handle a failed user trigger post cleanly" do
    init_fail_response 'user.tpost'

    uri = URI.parse "#{Pingfm::Client::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    @params.merge!({'title' => '', 'body' => 'test message',
                    'trigger' => '@trigger', 'debug' => 0})
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.tpost('test message', '@trigger')
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end
end
