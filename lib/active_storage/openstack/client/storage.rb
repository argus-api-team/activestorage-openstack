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

        def get_object(key)
          https_client.request(
            prepare_request do
              GetObject.new(uri: absolute_uri(key)).request
            end
          )
        end

        def put_object(key, file, checksum: nil)
          https_client.request(
            prepare_request do
              PutObject.new(
                file: file,
                uri: absolute_uri(key),
                checksum: checksum
              ).request
            end
          )
        end

        def delete_object(key)
          https_client.request(
            prepare_request do
              DeleteObject.new(uri: absolute_uri(key)).request
            end
          )
        end

        def show_object_metadata(key)
          https_client.request(
            prepare_request do
              ShowObjectMetadata.new(uri: absolute_uri(key)).request
            end
          )
        end

        def list_objects(**options)
          https_client.request(
            prepare_request do
              ListObjects.new(uri: uri, options: options).request
            end
          )
        end

        def create_temporary_uri(key, http_method, **options)
          CreateTemporaryURI.new(
            uri: absolute_uri(key),
            http_method: http_method,
            options: options
          ).generate
        end

        def temporary_url(key, http_method, **options)
          create_temporary_uri(key, http_method, options).to_s
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

        def absolute_uri(key)
          URI("#{uri}/#{key}")
        end
      end
    end
  end
end
