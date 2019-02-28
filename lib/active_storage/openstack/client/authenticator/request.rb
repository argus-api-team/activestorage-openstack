# frozen_string_literal: true

require_relative '../../helpers/https_client'

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Authenticator
        autoload :Response, File.expand_path('response', __dir__)

        # Prepares authentication request.
        class Request
          include Helpers::HTTPSClient

          attr_reader :credentials, :uri

          delegate :username, :password, to: :credentials

          def initialize(credentials:, uri:)
            @credentials = credentials
            @uri = uri
          end

          def call
            set_headers
            set_body
            https_client.request(request)
          end

          def response_to_cache
            response.to_cache
          end

          private

          def set_headers
            request.add_field('Content-Type', 'application/json')
          end

          def request
            @request ||= Net::HTTP::Post.new(uri)
          end

          def response
            @response ||= Response.new(call)
          end

          def set_body
            request.body = payload
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
        end
        private_constant :Request
      end
    end
  end
end
