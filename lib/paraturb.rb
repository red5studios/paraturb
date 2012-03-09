require 'curb'
require 'nokogiri'

require_relative 'paraturb/sla'
require_relative 'paraturb/ticket'
require_relative 'paraturb/customer'

module Paraturb
	class Paraturb
		attr_accessor :enforce_required_fields
		attr_reader :api_host,:account_id,:dept_id

		# Debugging accessors, set upon requests
		attr_reader :http_request_url,:http_post_body,:http_response,:parsed_response

		def initialize(options)
			@api_host = options[:api_host]
			@token = options[:token]
			@account_id = options[:account_id]
			@dept_id = options[:dept_id]
			@enforce_required_fields = options[:enforce_required_fields] || false
		end

		def request_url(options)
			object_type = options[:object_type] || 'Ticket'
			object_id = options[:object_id] || nil
			operation = options[:operation] || nil
			get_params = options[:params] || {}

			request_url = "#{@api_host}/api/v1/#{@account_id}/#{@dept_id}/#{object_type}"

			case operation
				when "schema","status","view","upload"
					request_url += "/#{operation}"
				else
					request_url += "/"
					request_url += "#{object_id}" if object_id
			end

			request_url += "?_token_=#{@token}&_enforceRequiredFields_=#{@enforce_required_fields}"

			get_params.each do |k,v|
				request_url += "&#{k}="
				if v.is_a? Array
					request_url += v.join(',')
				else
					request_url += "#{v}"
				end
			end

			@http_request_url = request_url
		end

		def request(options)
			method = options[:method] || 'get'
			method = 'post' if options[:post]
			method = 'put' if options[:put]

			case method
				when 'post'
					@http_response = Curl::Easy.new(request_url(options))
					@http_response.http_post(options[:post])
				when 'put'
					@http_response = Curl::Easy.new(request_url(options))
					@http_response.http_put(options[:put])
				when 'delete'
					@http_response = Curl::Easy.http_delete(request_url(options))
				else #get
					@http_response = Curl::Easy.perform(request_url(options))
			end

			#TODO: Check for HTTP errors here

			return parse_response(@http_response.body_str)
		end

		def parse_response(response)
			@parsed_response = Nokogiri::Slop(response)
		end

		def build_request(object_type,params)
			builder = Nokogiri::XML::Builder.new do |xml|
				xml.send(object_type) {
					params.each do |k,v|
						attributes = {}

						if k =~ /Custom_Field/
							attributes['id'] = k.sub("Custom_Field","")
							k = "Custom_Field"
						end

						if v.is_a? Array
							xml.send(k,attributes) {
								v.each_with_index do |values,i|
									xml.send(v[0],values) if i > 0
								end
							}
						else
							xml.send(k,v,attributes)
						end
					end
				}
			end

			@http_post_body = builder.to_xml
		end

		def fetch_one(object_type,response)
			if response.css(object_type).count > 0
				return response.css(object_type).first
			else
				return false
			end
		end

		def schema(object_type)
			request({:object_type => object_type,:operation => 'schema'})
		end
	end
end