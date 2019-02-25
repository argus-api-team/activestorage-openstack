# frozen_string_literal: true

module ActiveStorage
  module Openstack
    class Client
      # :reek:IrresponsibleModule
      class Authenticator
        # Prepares authentication request.
        class Request
          attr_reader :credentials, :https_client, :uri

          delegate :username, :password, to: :credentials

          def initialize(credentials:, uri:)
            @credentials = credentials
            @uri = uri
            @https_client = Net::HTTP.new(uri.host, uri.port)
          end

          def call
            set_ssl
            set_headers
            set_body
            https_client.request(request)
          end

          private

          def set_ssl
            https_client.use_ssl = true
            https_client.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          def set_headers
            request['Content-Type'] = 'application/json'
          end

          def request
            @request ||= Net::HTTP::Post.new(uri)
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
