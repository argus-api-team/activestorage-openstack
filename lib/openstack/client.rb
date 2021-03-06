# frozen_string_literal: true

module Openstack
  # Defines OpenStack client behaviours.
  class Client
    include ActiveModel::Model

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
      @authenticator ||= Authenticator.new(
        username: username,
        password: password,
        cache: cache
      )
    end

    def storage(container:, region:)
      @storage ||= Storage.new(
        authenticator: authenticator,
        container: container,
        region: region
      )
    end
  end
end
