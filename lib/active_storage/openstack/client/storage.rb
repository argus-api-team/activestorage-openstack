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

        load_path = File.expand_path('storage', __dir__)
        autoload :DeleteObject, "#{load_path}/delete_object"
        autoload :GetObject, "#{load_path}/get_object"
        autoload :ObjectStoreURL, "#{load_path}/object_store_url"
        autoload :PutObject, "#{load_path}/put_object"
        autoload :ShowObjectMetadata, "#{load_path}/show_object_metadata"

        attr_reader :authenticator, :container, :region

        delegate :authenticate_request,
                 to: :authenticator

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
          @uri ||= URI(ObjectStoreURL.new(
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

        def put_object(file, path, checksum: nil)
          request = authenticate_request do
            PutObject.new(
              file: file,
              uri: absolute_uri(path),
              checksum: checksum
            ).request
          end

          https_client.request(request)
        end

        def delete_object(path)
          request = authenticate_request do
            DeleteObject.new(uri: absolute_uri(path)).request
          end

          https_client.request(request)
        end

        def show_object_metadata(path)
          request = authenticate_request do
            ShowObjectMetadata.new(uri: absolute_uri(path)).request
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
