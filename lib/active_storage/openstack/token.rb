# frozen_string_literal: true

require 'net/http'

module ActiveStorage
  module Openstack
    # Token allows to get an authentication token from OpenStack API.
    class Token
      attr_reader :username, :password, :uri

      def initialize(username:, password:, url:)
        @username = username
        @password = password
        @uri = URI(url)
      end

      def get
        prepare_request
        response.token
      end

      def payload
        <<~JSON
          {
            "auth": {
              "identity": {
                "methods": [
                  "password"
                ],
                "password": {
                  "user": {
                    "name": "#{username}",
                    "domain": {
                      "id": "default"
                    },
                    "password": "#{password}"
                  }
                }
              }
            }
          }
        JSON
      end

      def cache_key
        "openstack/token-#{username}"
      end

      # Response simplifies interaction with the request response.
      class Response
        attr_reader :request

        delegate :code, :message, :body, to: :request

        def initialize(request)
          @request = request
        end

        def headers
          request.each_header.to_h
        end

        def token
          headers.dig('x-subject-token')
        end

        def to_h
          {
            'headers' => headers,
            'token' => token,
            'code' => code,
            'message' => message,
            'body' => body_as_hash
          }
        end

        private

        def body_as_hash
          JSON.parse(body)
        rescue JSON::ParserError
          {}
        end
      end
      private_constant :Response

      private

      def prepare_request
        set_ssl
        set_headers
        set_body
      end

      def set_ssl
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      def set_headers
        request['Content-Type'] = 'application/json'
      end

      def set_body
        request.body = payload
      end

      def http
        @http ||= Net::HTTP.new(uri.host, uri.port)
      end

      def request
        @request ||= Net::HTTP::Post.new(uri.request_uri)
      end

      def response
        @response ||= Response.new(http.request(request))
      end
    end
  end
end
