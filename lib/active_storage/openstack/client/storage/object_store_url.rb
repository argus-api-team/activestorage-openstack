# frozen_string_literal: true

require_relative '../../helpers/cache_readable'

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # Extracts the object store URL from cached payload mathing the
        # specified region.
        class ObjectStoreURL
          include Helpers::CacheReadable

          attr_reader :authenticator, :container, :region

          delegate :cache, :cache_key, :authenticate, to: :authenticator

          def initialize(authenticator:, container:, region:)
            @authenticator = authenticator
            @container = container
            @region = region
          end

          def call
            "#{regionized_object_store_url}/#{container}"
          end

          private

          def regionized_object_store_url
            object_store_endpoints.find do |endpoint|
              endpoint.fetch('region') == region
            end.fetch('url')
          end

          def object_store_endpoints
            catalog_collection.find do |catalog|
              catalog.fetch('type') == 'object-store'
            end.fetch('endpoints', [])
          end

          def catalog_collection
            read_from_cache.dig('body', 'token', 'catalog') || []
          end
        end
        private_constant :ObjectStoreURL
      end
    end
  end
end
