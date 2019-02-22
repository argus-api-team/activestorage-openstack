# frozen_string_literal: true

require 'net/http'

module ActiveStorage
  module Openstack
    # Token allows to get an authentication token from OpenStack API.
    class Token
      attr_reader :username, :password, :uri, :cache

      def initialize(username:, password:, url:)
        @username = username
        @password = password
        @uri = URI(url)
        @cache = Rails.cache
      end

      def get
        prepare_request
        cache_response if token_expired?
        read_token_from_cache
      end

      def payload
        <<~JSON.squish
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

        def expires_at
          Time.parse(body_as_hash.dig('token', 'expires_at'))
        rescue TypeError
          nil
        end

        def to_h
          {
            headers: headers,
            token: token,
            expires_at: expires_at,
            code: code,
            message: message,
            body: body_as_hash
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

      def token_expired?
        read_from_cache.fetch('expires_at') < Time.now
      rescue TypeError
        true
      end

      def cache_response
        cache.write(cache_key, response.to_h.to_json)
      end

      def read_token_from_cache
        read_from_cache.fetch('token')
      end

      def read_from_cache
        @read_from_cache ||= JSON.parse(cache.read(cache_key))
      end
    end
  end
end
