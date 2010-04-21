# Ping.fm Ruby Client
require 'net/http'
require 'rexml/document' # TODO: Rewrite this to use something faster (Nokogiri, possibly).

module Pingfm

  # MUST NOT end with a trailing slash, as this string is interpolated like this:
  # "#{API_URL}/user.services"
  # FIXME: This should be handled better; not so brittle as to break on a trailing slash.
  API_URL = 'http://api.ping.fm/v1'

  class Client

  	def initialize(api_key, user_app_key)
  		@api_key = api_key
  		@user_app_key = user_app_key
  	end

  	# Validates API key and user APP key
  	# if successful returns:
  	#   {'status' => 'OK'}
  	# if unsuccessful returns:
  	#   {'status' => 'FAIL', 'message' => 'message what went wrong'}
  	def validate
  	  response = get_response('user.validate')
  		if response.elements['rsp'].attributes['status'] == 'OK'
  			return status_ok
  		else
  			return status_fail(response)
  		end
  	end

    # Return a complete list of supported services
    # if successful returns:
    #   {'status' => 'OK', 'services' => [{'id' => 'serviceid', 'name' => 'servicename', 'trigger' => 'servicetrigger', 'url' => 'serviceurl', 'icon' => 'serviceicon'}, ...]}
    # if unsuccessful returns:
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

  	# Returns a list of services the user has set up through Ping.fm
  	# if successful returns:
    #   {'status' => 'OK', 'services' => [{'id' => 'serviceid', 'name' => 'servicename', 'trigger' => 'servicetrigger', 'url' => 'serviceurl', 'icon' => 'serviceicon', 'methods' => 'status,blog'}, ...]}
  	# if unsuccessful returns:
  	#   {'status' => 'FAIL', 'message' => 'message what went wrong'}
  	def services
  	  response = get_response('user.services')
  		if response.elements['rsp'].attributes['status'] == 'OK'
  			services = status_ok()
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

  	# Returns a user's custom triggers
  	# if successful returns:
  	#   {'status' => 'OK', 'triggers' => [{'id' => 'triggerid', 'method' => 'triggermethod', 'services' => [{'id' => 'serviceid', 'name' => 'servicename'}, ...]}, ...]}
  	# if unsuccessful returns:
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

  	# Returns the last <tt>limit</tt> messages a user has posted through Ping.fm
  	# Optional arguments:
  	# limit = limit the results returned, default is 25
  	# order = which direction to order the returned results by date, default is DESC (descending)
  	# if successful returns:
  	#   {'status' => 'OK', 'messages' => [{'id' => 'messageid', 'method' => 'messsagemethod', 'rfc' => 'date', 'unix' => 'date', 'title' => 'messagetitle', 'body' => 'messagebody', 'services' => [{'id' => 'serviceid', 'name' => 'servicename'}, ...]}, ...]}
  	# if unsuccessful returns:
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

  	# Posts a message to the user's Ping.fm services
  	# Arguments:
  	# body = message body
  	# Optional arguments:
  	# title = title of the posted message, title is required for 'blog' post method
  	# post_method = posting method; either 'default', 'blog', 'microblog' or 'status.'
  	# service = a single service to post to
  	# debug = set debug to 1 to avoid posting test data
  	# if successful returns:
  	#   {'status' => 'OK'}
  	# if unsuccessful returns:
  	#   {'status' => 'FAIL', 'message' => 'message what went wrong'}
  	def post(body, title = '', post_method = 'default', service = '', debug = 0)
  	  response = get_response('user.post',
  	                          'body' => body, 'title' => title,
  	                          'post_method' => post_method, 'service' => service,
  	                          'debug' => debug)
  		if response.elements['rsp'].attributes['status'] == 'OK'
  			return status_ok
  		else
  			return status_fail(response)
  		end
  	end

  	# Posts a message to the user's Ping.fm services using one of their custom triggers
  	# Arguments:
  	# body = message body
  	# trigger = custom trigger the user has defined from the Ping.fm website
  	# Optional arguments:
  	# title = title of the posted message, title is required for 'blog' post method
  	# debug = set debug to 1 to avoid posting test data
  	# if successful returns:
  	#   {'status' => 'OK'}
  	# if unsuccessful returns:
  	#   {'status' => 'FAIL', 'message' => 'message what went wrong'}
  	def tpost(body, trigger, title = '', debug = 0)
  	  response = get_response('user.tpost',
  	                          'body' => body, 'title' => title,
  	                          'trigger' => trigger, 'debug' => debug)
  		if response.elements['rsp'].attributes['status'] == 'OK'
  			return status_ok
  		else
  			return status_fail(response)
  		end
  	end

  	private

    # Gets a particular ping.fm response.
    # <tt>type</tt>: The service type (ex. 'user.services'). Gets appended to <tt>API_URL</tt>.
    # <tt>parameters</tt>: Optional (depending on the <tt>type</tt>) parameters to be passed along
    # with the request.  The API key and user app key are merged with this on every call.
    def get_response(type, parameters = {})
      parameters.merge!('api_key' => @api_key, 'user_app_key' => @user_app_key)
  		REXML::Document.new(http_request("#{API_URL}/#{type}", parameters))
    end

    # This makes the actual HTTP request.
  	def http_request(url, parameters)
  		response = Net::HTTP.post_form(URI.parse(url), parameters)
  		return response.body
  	end

    # Successful response.
  	def status_ok
  		return {'status' => 'OK'}
  	end

    # Failed response.
  	def status_fail(response)
      if response.elements.include? 'rsp/message'
        message = response.elements['rsp/message'].text
      else
        message = "Unknown error from Ping.fm"
      end

  		return {'status' => 'FAIL', 'message' => message}
  	end

  end

end
