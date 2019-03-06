# frozen_string_literal: true

module ActiveStorage
  class Service
    # Wraps OpenStack Object Storage Service as an Active Storage service.
    class OpenstackService < Service
      attr_reader :config, :credentials, :storage, :client

      def initialize(credentials:, container:, region:, **config)
        @config = config
        @credentials = credentials
        @client = Openstack::Client.new username: credentials.fetch(:username),
                                        password: credentials.fetch(:api_key)
        @storage = client.storage container: container,
                                  region: region
      end

      # :reek:LongParameterList
      def upload(key, io, checksum: nil, **_options)
        instrument :upload, key: key, checksum: checksum do
          storage.put_object(key, io, checksum: checksum)
        end
      end

      # :reek:LongParameterList
      # :reek:UnusedParameters:
      # rubocop:disable Lint/UnusedMethodArgument
      def url(key, expires_in:, disposition:, filename:, content_type:)
        instrument :url, key: key do |payload|
          payload[:url] = storage.temporary_url(
            key,
            'GET',
            expires_in: expires_in,
            disposition: disposition,
            filename: filename
          )
          payload.fetch(:url)
        end
      end

      def url_for_direct_upload(key, expires_in:, filename:, **_options)
        instrument :url, key: key do |payload|
          payload[:url] = storage.temporary_url(
            key,
            'PUT',
            expires_in: expires_in,
            filename: filename
          )
          payload.fetch(:url)
        end
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def download(key)
        instrument :download, key: key do
          storage.get_object(key)
        end
      end

      def delete(key)
        instrument :delete, key: key do
          storage.delete_object(key)
        end
      end

      def delete_prefixed(prefix)
        instrument :delete_prefixed, prefix: prefix do
          keys = JSON.parse(
            storage.list_objects(prefix: prefix).body
          ).map do |object|
            "/#{storage.container}/#{object.fetch(:name)}"
          end

          storage.bulk_delete_objects(keys)
        end
      end

      def exist?(key)
        instrument :exist, key: key do |payload|
          payload[:exist] = storage.show_object_metadata(key).is_a?(Net::HTTPOK)
          payload.fetch(:exist)
        end
      end
    end
  end
end
