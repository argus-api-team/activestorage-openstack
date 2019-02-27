# frozen_string_literal: true

require_relative '../helpers/cache_readable'

module ActiveStorage
  module Openstack
    class Client
      # It retrieves token from OpenStack API and caches it.
      class Authenticator
        include ActiveModel::Model
        include Helpers::CacheReadable

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

        def authenticate
          cache_response if token_expired?
          case read_from_cache.fetch('code')
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

        def cache_response
          cache.write(cache_key, Response.new(request).to_cache)
        end
      end
    end
  end
end
