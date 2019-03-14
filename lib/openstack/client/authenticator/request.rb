# frozen_string_literal: true

module Openstack
  # :reek:IrresponsibleModule
  class Client
    # :reek:IrresponsibleModule
    class Authenticator
      # Handles authentication request.
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

        private

        def set_headers
          request.add_field('Content-Type', 'application/json')
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
