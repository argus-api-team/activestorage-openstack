# frozen_string_literal: true

module ActiveStorage
  module Openstack
    module Helpers
      # Methods to interact with cache.
      module CacheReaderable
        def cache_key
          "openstack/token-#{username}"
        end

        def read_from_cache
          @read_from_cache ||= JSON.parse(cache.read(cache_key))
        rescue TypeError
          null_cache_placeholder
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
