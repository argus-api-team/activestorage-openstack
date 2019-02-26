# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # Defines OpenStack client behaviours.
    class Client
      include ActiveModel::Model

      autoload :Authenticator, File.expand_path('client/authenticator', __dir__)

      attr_reader :username, :password, :cache

      validates :username,
                :password,
                presence: true

      delegate :authenticate, :authenticate_request, to: :authenticator

      def initialize(username:, password:, cache: Rails.cache)
        @username = username
        @password = password
        @cache = cache
      end

      def authenticator
        Authenticator.new(
          username: username,
          password: password,
          cache: cache
        )
      end
    end
  end
end
