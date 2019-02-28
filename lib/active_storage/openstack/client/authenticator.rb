# frozen_string_literal: true

require_relative '../helpers/cache_readerable'

module ActiveStorage
  module Openstack
    class Client
      # It retrieves token from OpenStack API and caches it.
      class Authenticator
        include ActiveModel::Model
        include Helpers::CacheReaderable

        load_path = File.expand_path('authenticator', __dir__)
        autoload :Request, "#{load_path}/request"
        autoload :Response, "#{load_path}/response"

        attr_reader :cache,
                    :password,
                    :uri,
                    :username

        validates :password,
                  :username,
                  presence: true

        def initialize(
          username:,
          password:,
          authentication_url: Rails.application.config.x.openstack
                                   .fetch(:authentication_url),
          cache: Rails.cache
        )
          @username = username
          @password = password
          @uri = URI(authentication_url)
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

        def credentials
          OpenStruct.new(username: username, password: password)
        end

        def request
          @request ||= Request.new(credentials: credentials, uri: uri).call
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
