# frozen_string_literal: true

require_relative '../helpers/https_client'

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # It interacts with Containers/Objects OpenStack API.
      class Storage
        include ActiveModel::Model
        include Helpers::HTTPSClient

        autoload :ObjectStoreEndpointURL,
                 File.expand_path('storage/object_store_endpoint_url', __dir__)
        autoload :GetObject, File.expand_path('storage/get_object', __dir__)
        autoload :PutObject, File.expand_path('storage/put_object', __dir__)

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
          @uri ||= URI(ObjectStoreEndpointURL.new(
            authenticator: authenticator,
            container: container,
            region: region
          ).call)
        end

        def get_object(path)
          request = authenticate_request do
            GetObject.new(uri: absolute_uri(path)).request
          end

          https_client.request(request)
        end

        def put_object(file, path)
          request = authenticate_request do
            PutObject.new(file: file, uri: absolute_uri(path)).request
          end

          https_client.request(request)
        end

        private

        def absolute_uri(path)
          URI(uri.to_s + path)
        end
      end
    end
  end
end
