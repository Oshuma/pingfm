require 'net/http'
require 'rexml/document' # TODO: Rewrite this to use something faster (Nokogiri, possibly).

module Pingfm
  # TODO: The status_ok and status_fail methods need a little thought.
  class Client

    # The registered API key for the Ping.fm Ruby library client.
    API_KEY = '5fcb8b7041d5c32c7e1e60dc076989ba'

    # MUST NOT end with a trailing slash, as this string is interpolated like this:
    # "#{API_URL}/user.services"
    # FIXME: This should be handled better; not so brittle as to break on a trailing slash.
    API_URL = 'http://api.ping.fm/v1'

    attr_reader :user_app_key

    def initialize(user_app_key)
      @user_app_key = user_app_key
    end

    # Returns the last <tt>limit</tt> messages a user has posted through Ping.fm.
    #
    # Optional arguments:
    # [limit] Limit the results returned; default is 25.
    # [order] = Which direction to order the returned results by date; default is descending.
    #
    # If successful returns:
    #   {'status' => 'OK', 'messages' => [{'id' => 'messageid', 'method' => 'messsagemethod', 'rfc' => 'date', 'unix' => 'date', 'title' => 'messagetitle', 'body' => 'messagebody', 'services' => [{'id' => 'serviceid', 'name' => 'servicename'}, ...]}, ...]}
    # If unsuccessful returns:
    #   {'status' => 'FAIL', 'message' => 'message what went wrong'}
    def latest(limit = 25, order = 'DESC')
      response = get_response('user.latest', 'limit' => limit, 'order' => order)
      if response.elements['rsp'].attributes['status'] == 'OK'
        latest = status_ok
        latest['messages'] = []
        response.elements.each('rsp/messages/message') do |message|
          latest['messages'].push({})
          latest['messages'].last['id'] = message.attributes['id']
          latest['messages'].last['method'] = message.attributes['method']
          latest['messages'].last['rfc'] = message.elements['date'].attributes['rfc']
          latest['messages'].last['unix'] = message.elements['date'].attributes['unix']

          if message.elements['*/title'] != nil
            latest['messages'].last['title'] = message.elements['*/title'].text
          else
            latest['messages'].last['title'] = ''
          end
          if message.elements['location'] != nil
            latest['messages'].last['location'] = message.elements['location'].text
          else
            latest['messages'].last['location'] = ''
          end
          latest['messages'].last['body'] = message.elements['*/body'].text
          latest['messages'].last['services'] = []
          message.elements.each('services/service') do |service|
            latest['messages'].last['services'].push({'id' => service.attributes['id'], 'name' => service.attributes['name']})
          end
        end
        return latest
      else
        return status_fail(response)
      end
    end

    # Posts a message to the user's Ping.fm services.
    #
    # Arguments:
    # [body] Message body.
    #
    # Optional <tt>args</tt>:
    # [title] Title of the posted message; title is required for 'blog' post method.
    # [post_method] Posting method; either 'default', 'blog', 'microblog' or 'status'.
    # [service] A single service to post to.
    # [debug] Set debug to 1 to avoid posting test data.
    #
    # If successful returns:
    #   {'status' => 'OK'}
    # If unsuccessful returns:
    #   {'status' => 'FAIL', 'message' => 'message what went wrong'}
    def post(body, opts = { :title => '', :post_method => 'default', :service => '', :debug => false })
      response = get_response('user.post',
                              'body' => body, 'title' => opts[:title],
                              'post_method' => opts[:post_method], 'service' => opts[:service],
                              'debug' => (opts[:debug] ? 1 : 0))

      if response.elements['rsp'].attributes['status'] == 'OK'
        return status_ok
      else
        return status_fail(response)
      end
    end

    # Returns a list of services the user has set up through Ping.fm.
    #
    # If successful returns:
    #   {'status' => 'OK', 'services' => [{'id' => 'serviceid', 'name' => 'servicename', 'trigger' => 'servicetrigger', 'url' => 'serviceurl', 'icon' => 'serviceicon', 'methods' => 'status,blog'}, ...]}
    # If unsuccessful returns:
    #   {'status' => 'FAIL', 'message' => 'message what went wrong'}
    def services
      response = get_response('user.services')
      if response.elements['rsp'].attributes['status'] == 'OK'
        services = status_ok
        services['services'] = []
        response.elements.each('rsp/services/service') do |service|
          services['services'].push({'id' => service.attributes['id'],
                        'name' => service.attributes['name'],
                        'trigger' => service.elements['trigger'].text,
                        'url' => service.elements['url'].text,
                        'icon' => service.elements['icon'].text,
                        'methods' => service.elements['methods'].text})
        end
        return services
      else
        return status_fail(response)
      end
    end

    # Return a complete list of supported services.
    #
    # If successful returns:
    #   {'status' => 'OK', 'services' => [{'id' => 'serviceid', 'name' => 'servicename', 'trigger' => 'servicetrigger', 'url' => 'serviceurl', 'icon' => 'serviceicon'}, ...]}
    # If unsuccessful returns:
    #   {'status' => 'FAIL', 'message' => 'message what went wrong'}
    def system_services
      response = get_response('system.services')
      if response.elements['rsp'].attributes['status'] == 'OK'
        services = status_ok
        services['services'] = []
        response.elements.each('rsp/services/service') do |service|
          services['services'].push({'id'      => service.attributes['id'],
                                     'name'    => service.attributes['name'],
                                     'trigger' => service.elements['trigger'].text,
                                     'url'     => service.elements['url'].text,
                                     'icon'    => service.elements['icon'].text})
        end
        return services
      else
        return status_fail(response)
      end
    end

    # Posts a message to the user's Ping.fm services using one of their custom triggers.
    #
    # Arguments:
    # [body] Message body.
    # [trigger] Custom trigger the user has defined from the Ping.fm website.
    #
    # Optional arguments:
    # [title] Title of the posted message; title is required for 'blog' post method.
    # [debug] Set debug to +true+ to avoid posting test data.
    #
    # If successful returns:
    #   {'status' => 'OK'}
    # If unsuccessful returns:
    #   {'status' => 'FAIL', 'message' => 'message what went wrong'}
    def tpost(body, trigger, opts = { :title => '', :debug => false })
      response = get_response('user.tpost',
                              'body' => body, 'title' => opts[:title],
                              'trigger' => trigger, 'debug' => (opts[:debug] ? 1 : 0))
      if response.elements['rsp'].attributes['status'] == 'OK'
        return status_ok
      else
        return status_fail(response)
      end
    end

    # Returns a user's custom triggers.
    #
    # If successful returns:
    #   {'status' => 'OK', 'triggers' => [{'id' => 'triggerid', 'method' => 'triggermethod', 'services' => [{'id' => 'serviceid', 'name' => 'servicename'}, ...]}, ...]}
    # If unsuccessful returns:
    #   {'status' => 'FAIL', 'message' => 'message what went wrong'}
    def triggers
      response = get_response('user.triggers')
      if response.elements['rsp'].attributes['status'] == 'OK'
        triggers = status_ok
        triggers['triggers'] = []
        response.elements.each('rsp/triggers/trigger') do |trigger|
          triggers['triggers'].push({'id' => trigger.attributes['id'], 'method' => trigger.attributes['method'], 'services' => []})

          trigger.elements.each('services/service') do |service|
            triggers['triggers'].last['services'].push({'id' => service.attributes['id'], 'name' => service.attributes['name']})
          end
        end
        return triggers
      else
        return status_fail(response)
      end
    end

    # Returns the full user app key from the provided <tt>mobile_key</tt>.
    def user_key(mobile_key)
      response = get_response('user.key', 'mobile_key' => mobile_key)
      if response.elements['rsp'].attributes['status'] == 'OK'
        app_key = response.elements['rsp'].elements['key'].text
        status_ok('app_key' => app_key)
      else
        status_fail(response)
      end
    end

    # Validates the API key and user APP key.
    #
    # If successful returns:
    #   {'status' => 'OK'}
    # If unsuccessful returns:
    #   {'status' => 'FAIL', 'message' => 'message what went wrong'}
    def validate
      response = get_response('user.validate')
      if response.elements['rsp'].attributes['status'] == 'OK'
        return status_ok
      else
        return status_fail(response)
      end
    end

    private

    # Gets a particular ping.fm response.
    #
    # [type] The service type (ex. 'user.services'). Gets appended to <tt>API_URL</tt>.
    # [parameters] Optional (depending on the <tt>type</tt>) parameters to be passed along.  with the request.  The API key and user app key are merged with this on every call.
    def get_response(type, parameters = {})
      parameters.merge!('api_key' => API_KEY, 'user_app_key' => @user_app_key)
      REXML::Document.new(http_request("#{API_URL}/#{type}", parameters))
    end

    # This makes the actual HTTP request.
    def http_request(url, parameters)
      response = Net::HTTP.post_form(URI.parse(url), parameters)
      return response.body
    end

    # Successful response.
    def status_ok(info = {})
      return {'status' => 'OK'}.merge(info)
    end

    # Failed response.
    def status_fail(response)
      if response.elements.include? 'rsp/message'
        message = response.elements['rsp/message'].text
      else
        message = "Unknown error from Ping.fm."
      end

      return {'status' => 'FAIL', 'message' => message}
    end

  end
end
