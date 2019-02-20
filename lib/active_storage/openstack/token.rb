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
        set_ssl
        set_headers
        set_body
        http.request(request).each_header.to_h.fetch('x-subject-token')
      end

      def payload # rubocop:disable Metrics/MethodLength
        {
          'auth' => {
            'identity' => {
              'methods' => [
                'password'
              ],
              'password' => {
                'user' => {
                  'name' => username,
                  'domain' => {
                    'name' => 'Default'
                  },
                  'password' => password
                }
              }
            }
          }
        }.to_json
      end

      private

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
    end
  end
end
