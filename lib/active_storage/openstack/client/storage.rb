# frozen_string_literal: true

require_relative '../helpers/https_client'

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # It interacts with Containers/Objects OpenStack API.
      class Storage
        include ActiveModel::Model
        include ::ActiveStorage::Openstack::Helpers::HTTPSClient

        autoload :ObjectStoreEndpointURL,
                 File.expand_path('storage/object_store_endpoint_url', __dir__)

        attr_reader :authenticator, :container, :region

        delegate :cache, :cache_key, :authenticate_request, to: :authenticator

        validates :authenticator,
                  :container,
                  :region,
                  presence: true

        def initialize(authenticator:, container:, region:)
          @authenticator = authenticator
          @container = container
          @region = region
        end

        def uri
          URI(ObjectStoreEndpointURL.new(
            authenticator: authenticator,
            container: container,
            region: region
          ).call)
        end

        def get_object(path)
          absolute_uri = URI(uri.to_s + path)
          request = authenticate_request do
            Net::HTTP::Get.new(absolute_uri)
          end

          https_client.request(request)
        end
      end
    end
  end
end
