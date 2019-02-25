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
