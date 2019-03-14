# frozen_string_literal: true

module Openstack
  class Client
    # It retrieves token from OpenStack API and caches it.
    class Authenticator
      include ActiveModel::Model
      include Helpers::CacheReaderable

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
        uri: Rails.application.config.x.openstack.fetch(:authentication_url),
        cache: Rails.cache
      )
        @username = username
        @password = password
        @uri = URI(uri)
        @cache = cache
      end

      def authenticate
        cache_response if token_expired?
        authentication_succeed?
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

      def cache_response
        cache.write(cache_key, request.body_to_cache)
      end

      def token_expired?
        read_from_cache.fetch('expires_at') < Time.now
      rescue TypeError, NoMethodError
        true
      end

      def authentication_succeed?
        case read_from_cache.fetch('code')
        when 201
          true
        else
          false
        end
      end

      def request
        @request ||= Request.new(
          credentials: credentials,
          uri: uri
        ).call.extend(Helpers::CacheableBody)
      end

      def credentials
        OpenStruct.new(username: username, password: password)
      end
    end
  end
end
