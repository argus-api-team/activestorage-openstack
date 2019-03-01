# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # It interacts with Containers/Objects OpenStack API.
      class Storage
        include ActiveModel::Model
        include Helpers::HTTPSClient

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
          https_client.request(
            prepare_request do
              GetObject.new(uri: absolute_uri(path)).request
            end
          )
        end

        def put_object(file, path, checksum: nil)
          https_client.request(
            prepare_request do
              PutObject.new(
                file: file,
                uri: absolute_uri(path),
                checksum: checksum
              ).request
            end
          )
        end

        def delete_object(path)
          https_client.request(
            prepare_request do
              DeleteObject.new(uri: absolute_uri(path)).request
            end
          )
        end

        def show_object_metadata(path)
          https_client.request(
            prepare_request do
              ShowObjectMetadata.new(uri: absolute_uri(path)).request
            end
          )
        end

        def list_objects(path, options = {})
          https_client.request(
            prepare_request do
              ListObjects.new(uri: absolute_uri(path), options: options).request
            end
          )
        end

        private

        def prepare_request
          return unless block_given?

          authenticate_request do
            yield.tap do |request|
              request.add_field('Accept', 'application/json')
            end
          end
        end

        def absolute_uri(path)
          URI(uri.to_s + path)
        end
      end
    end
  end
end
