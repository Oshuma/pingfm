require 'rspec'
require "#{File.dirname(__FILE__)}/../lib/pingfm"

# TODO: Replace this XML string bullshit.
RSpec.configure do |config|
  def init_ok_response(service_type)
    @service_type = service_type
    @response = <<EOXML
<?xml version="1.0"?>
<rsp status="OK">
<transaction>12345</transaction>
<method>#{@service_type}</method>
</rsp>
EOXML
  end

  def init_fail_response(service_type)
    @service_type = service_type
    @response = <<EOXML
<?xml version="1.0"?>
<rsp status="FAIL">
  <transaction>12345</transaction>
  <method>#{@service_type}</method>
  <message>You suck</message>
</rsp>
EOXML
  end

  def init_service_response
    @service_type = 'user.services'
    @response = <<EOXML
<?xml version="1.0"?>
<rsp status="OK">
  <transaction>12345</transaction>
  <method>user.services</method>
  <services>
    <service id="twitter" name="Twitter">
      <trigger>@tt</trigger>
      <url>http://twitter.com/</url>
      <icon>http://p.ping.fm/static/icons/twitter.png</icon>
      <methods>microblog,status</methods>
    </service>
    <service id="facebook" name="Facebook">
      <trigger>@fb</trigger>
      <url>http://www.facebook.com/</url>
      <icon>http://p.ping.fm/static/icons/facebook.png</icon>
      <methods>status</methods>
    </service>
  </services>
</rsp>
EOXML
  end

  def init_system_services_response
    @service_type = 'system.services'
    @response = <<EOXML
<?xml version="1.0"?>
<rsp status="OK">
  <transaction>12345</transaction>
  <method>system.services</method>
  <services>
    <service id="bebo" name="Bebo">
      <trigger>@be</trigger>
      <url>http://www.bebo.com/</url>
      <icon>http://p.ping.fm/static/icons/bebo.png</icon>
    </service>
    <service id="blogger" name="Blogger">
      <trigger>@bl</trigger>
      <url>http://www.blogger.com/</url>
      <icon>http://p.ping.fm/static/icons/blogger.png</icon>
    </service>
  </services>
</rsp>
EOXML
  end

  def init_trigger_response
    @service_type = 'user.triggers'
    @response = <<EOXML
<?xml version="1.0"?>
<rsp status="OK">
  <transaction>12345</transaction>
  <method>user.triggers</method>
  <triggers>
    <trigger id="twt" method="microblog">
      <services>
        <service id="twitter" name="Twitter"/>
      </services>
    </trigger>
    <trigger id="fb" method="status">
      <services>
        <service id="facebook" name="Facebook"/>
      </services>
    </trigger>
  </triggers>
</rsp>
EOXML
  end

  def init_latest_response
    @service_type = 'user.latest'
    @response = <<EOXML
<?xml version="1.0"?>
<rsp status="OK">
  <transaction>12345</transaction>
  <method>user.latest</method>
  <messages>
    <message id="12345" method="blog">
      <date rfc="Tue, 15 Apr 2008 13:56:18 -0500" unix="1234567890" />
      <services>
        <service id="blogger" name="Blogger"/>
      </services>
      <content>
        <title>SnVzdCBoYW5naW4nIG91dCE=</title>
        <body>R29pbmcgdG8gdGhlIHN0b3JlLg==</body>
      </content>
    </message>
    <message id="12345" method="microblog">
      <date rfc="Tue, 15 Apr 2008 13:56:18 -0500" unix="1234567890" />
      <services>
        <service id="twitter" name="Twitter"/>
      </services>
      <content>
        <body>R29pbmcgdG8gdGhlIHN0b3JlLg==</body>
      </content>
    </message>
    <message id="12345" method="status">
      <date rfc="Tue, 15 Apr 2008 13:56:18 -0500" unix="1234567890" />
      <services>
        <service id="twitter" name="Twitter"/>
        <service id="facebook" name="Facebook"/>
      </services>
      <content>
        <body>aXMgdGVzdGluZyBQaW5nLmZtIQ==</body>
      </content>
      <location>VHVsc2EsIE9L</location>
    </message>
  </messages>
</rsp>
EOXML
  end
end
