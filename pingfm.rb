# Ping.fm Ruby Class
# Version:   1.0.06072008
# Author:    Krunoslav Husak [h00s]
# Support:   kruno at binel d hr
#
# Copyright (C) 2008. Krunoslav Husak, http://h00s.net
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require "net/http"
require "rexml/document"
include REXML  

class Pingfm

	def initialize(api_key, user_app_key)
		@api_key = api_key
		@user_app_key = user_app_key
	end
	
	# Validates API key and user APP key
	# if successful returns:
	# {"status" => "OK"}
	# if unsuccessful returns:
	# {"status" => "FAIL", "message" => "message what went wrong"}
	def validate()
		response = Document.new(http_request("http://api.ping.fm/v1/user.validate", {"api_key" => @api_key, "user_app_key" => @user_app_key}))
		if response.elements["rsp"].attributes["status"] == "OK"
			return status_ok()
		else
			return status_fail(response)
		end
	end
	
	# Returns a list of services the user has set up through Ping.fm
	# if successful returns:
	# {"status" => "OK", services = [{"id" => "serviceid", "name" => "servicename", "methods" => "status,blog"}, ...]}
	# if unsuccessful returns:
	# {"status" => "FAIL", "message" => "message what went wrong"}
	def services()
		response = Document.new(http_request("http://api.ping.fm/v1/user.services", {"api_key" => @api_key, "user_app_key" => @user_app_key}))
		if response.elements["rsp"].attributes["status"] == "OK"
			services = status_ok()
			services["services"] = []
			response.elements.each("rsp/services/service") do |service|
				services["services"].push({"id" => service.attributes["id"], "name" => service.attributes["name"], "methods" => service.elements["methods"].text})
			end
			return services
		else
			return status_fail(response)
		end
	end

	# Returns a user's custom triggers
	# if successful returns:
	# {"status" => "OK", triggers = [{"id" => "triggerid", "method" => "triggermethod", "services" => [{"id" => "serviceid", "name" => "servicename"}, ...]}, ...]}
	# if unsuccessful returns:
	# {"status" => "FAIL", "message" => "message what went wrong"}
	def triggers()
		response = Document.new(http_request("http://api.ping.fm/v1/user.triggers", {"api_key" => @api_key, "user_app_key" => @user_app_key}))
		if response.elements["rsp"].attributes["status"] == "OK"
			triggers = status_ok()
			triggers["triggers"] = []
			response.elements.each("rsp/triggers/trigger") do |trigger|
				triggers["triggers"].push({"id" => trigger.attributes["id"], "method" => trigger.attributes["method"], "services" => []})
				
				trigger.elements.each("services/service") do |service|
					triggers["triggers"].last["services"].push({"id" => service.attributes["id"], "name" => service.attributes["name"]})
				end
			end
			return triggers
		else
			return status_fail(response)
		end
	end

	# Returns the last #{limit} messages a user has posted through Ping.fm
	# Optional arguments:
	# limit = limit the results returned, default is 25
	# order = which direction to order the returned results by date, default is DESC (descending)
	# if successful returns:
	# {"status" => "OK", "messages" => [{"id" => "messageid", "method" => "messsagemethod", "rfc" => "date", "unix" => "date", "title" => "messagetitle", "body" => "messagebody", "services" => [{"id" => "serviceid", "name" => "servicename"}, ...]}, ...]}
	# if unsuccessful returns:
	# {"status" => "FAIL", "message" => "message what went wrong"}
	def latest(limit = 25, order = "DESC")
		response = Document.new(http_request("http://api.ping.fm/v1/user.latest", {"api_key" => @api_key, "user_app_key" => @user_app_key, "limit" => limit, "order" => order}))
		if response.elements["rsp"].attributes["status"] == "OK"
			latest = status_ok()
			latest["messages"] = []
			response.elements.each("rsp/messages/message") do |message|
				latest["messages"].push({})
				latest["messages"].last["id"] = message.attributes["id"]
				latest["messages"].last["method"] = message.attributes["method"]
				latest["messages"].last["rfc"] = message.elements["date"].attributes["rfc"]
				latest["messages"].last["unix"] = message.elements["date"].attributes["unix"]

				if message.elements["*/title"] != nil
					latest["messages"].last["title"] = message.elements["*/title"].text
				else
					latest["messages"].last["title"] = ""
				end
				latest["messages"].last["body"] = message.elements["*/body"].text
				latest["messages"].last["services"] = []
				message.elements.each("services/service") do |service|
					latest["messages"].last["services"].push({"id" => service.attributes["id"], "name" => service.attributes["name"]})
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
	# title = title of the posted message, title is required for "blog" post method
	# post_method = posting method; either "default", "blog", "microblog" or "status."
	# service = a single service to post to
	# debug = set debug to 1 to avoid posting test data
	# if successful returns:
	# {"status" => "OK"}
	# if unsuccessful returns:
	# {"status" => "FAIL", "message" => "message what went wrong"}
	def post(body, title = "", post_method = "default", service = "", debug = 0)
		response = Document.new(http_request("http://api.ping.fm/v1/user.post", {"api_key" => @api_key, "user_app_key" => @user_app_key, "body" => body, "title" => title, "post_method" => post_method, "service" => service, "debug" => debug}))
		if response.elements["rsp"].attributes["status"] == "OK"
			return status_ok()
		else
			return status_fail(response)
		end
	end

	# Posts a message to the user's Ping.fm services using one of their custom triggers
	# Arguments:
	# body = message body
	# trigger = custom trigger the user has defined from the Ping.fm website
	# Optional arguments:
	# title = title of the posted message, title is required for "blog" post method
	# debug = set debug to 1 to avoid posting test data
	# if successful returns:
	# {"status" => "OK"}
	# if unsuccessful returns:
	# {"status" => "FAIL", "message" => "message what went wrong"}
	def tpost(body, trigger, title = "", debug = 0)
		response = Document.new(http_request("http://api.ping.fm/v1/user.tpost", {"api_key" => @api_key, "user_app_key" => @user_app_key, "body" => body, "trigger" => trigger, "title" => title, "debug" => debug}))
		if response.elements["rsp"].attributes["status"] == "OK"
			return status_ok()
		else
			return status_fail(response)
		end
	end

	private
	def http_request(url, parameters)
		response = Net::HTTP.post_form(URI.parse(url), parameters)
		return response.body
	end
	
	def status_ok()
		return {"status" => "OK"}
	end

	def status_fail(response)
		return {"status" => "FAIL", "message" => response.elements["rsp/message"].text}
	end

end
