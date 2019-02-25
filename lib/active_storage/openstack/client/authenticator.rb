# frozen_string_literal: true

module ActiveStorage
  module Openstack
    class Client
      # It retrieves token from OpenStack API and caches it.
      class Authenticator
        attr_reader :username, :password, :cache

        include ActiveModel::Model

        validates :username,
                  :password,
                  presence: true

        def initialize(username:, password:, cache: Rails.cache)
          @username = username
          @password = password
          @cache = cache
        end

        def cache_key
          "openstack/token-#{username}"
        end

        def authenticate
          cache_response if token_expired?
          case read_from_cache.fetch('code')
          when 201
            true
          else
            false
          end
        end

        def token
          read_from_cache.fetch('token')
        end

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
              code: Integer(code),
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
        private_constant :Request, :Response

        private

        def authentication_uri
          URI(Rails.application.config.x.openstack.fetch(:auth_url))
        end

        def credentials
          OpenStruct.new(username: username, password: password)
        end

        def request
          @request ||= Request.new(
            credentials: credentials,
            uri: authentication_uri
          ).call
        end

        def token_expired?
          read_from_cache.fetch('expires_at') < Time.now
        rescue TypeError, NoMethodError
          true
        end

        def read_from_cache
          @read_from_cache ||= JSON.parse(cache.read(cache_key))
        rescue TypeError
          failed_cache_placeholder
        end

        def cache_response
          cache.write(cache_key, Response.new(request).to_h.to_json)
        end

        # it's just a hash :reek:UtilityFunction
        def failed_cache_placeholder
          {
            headers: nil,
            token: nil,
            expires_at: nil,
            code: nil,
            message: nil,
            body: nil
          }.stringify_keys!
        end
      end
    end
  end
end
