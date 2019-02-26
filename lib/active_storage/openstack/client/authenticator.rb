# frozen_string_literal: true

module ActiveStorage
  module Openstack
    class Client
      # It retrieves token from OpenStack API and caches it.
      class Authenticator
        include ActiveModel::Model

        autoload :Request, File.expand_path('authenticator/request', __dir__)
        autoload :Response, File.expand_path('authenticator/response', __dir__)

        attr_reader :username, :password, :cache

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
          case parse_cached_response.fetch('code')
          when 201
            true
          else
            false
          end
        end

        def authenticate_request(&_request)
          return unless block_given?

          authenticate
          yield.tap do |request|
            request.add_field('x-auth-token', token)
          end
        end

        def token
          parse_cached_response.fetch('token')
        end

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
          parse_cached_response.fetch('expires_at') < Time.now
        rescue TypeError, NoMethodError
          true
        end

        def parse_cached_response
          @parse_cached_response ||= JSON.parse(cache.read(cache_key))
        rescue TypeError
          null_cache_placeholder
        end

        def cache_response
          cache.write(cache_key, Response.new(request).to_cache)
        end

        def null_cache_placeholder
          {
            'headers' => nil,
            'token' => nil,
            'expires_at' => nil,
            'code' => nil,
            'message' => nil,
            'body' => nil
          }
        end
      end
    end
  end
end
