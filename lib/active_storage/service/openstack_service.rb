# frozen_string_literal: true

module ActiveStorage
  class Service
    # Wraps OpenStack Object Storage Service as an Active Storage service.
    class OpenstackService < Service
      attr_reader :config, :credentials, :storage, :client

      def initialize(credentials:, container:, region:, **config)
        @config = config
        @credentials = credentials
        @client = ::Openstack::Client.new username: credentials.fetch(:username),
                                          password: credentials.fetch(:api_key)
        @storage = client.storage container: container,
                                  region: region
      end

      # :reek:LongParameterList
      def upload(key, io, checksum: nil, **_options)
        instrument :upload, key: key, checksum: checksum do
          handle_errors do
            storage.put_object(key, io, checksum: checksum)
          end
        end
      end

      # :reek:UnusedParameters
      def update_metadata(key, **metadata); end

      def download(key, &block)
        raise ActiveStorage::FileNotFoundError unless exist?(key)

        if block_given?
          instrument :streaming_download, key: key do
            stream(key, &block)
          end
        else
          instrument :download, key: key do
            storage.get_object(key).body
          end
        end
      end

      def download_chunk(key, range)
        raise ActiveStorage::FileNotFoundError unless exist?(key)

        instrument :download_chunk, key: key, range: range do
          storage.get_object_by_range(key, range).body
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
          ).map { |object| "/#{storage.container}/#{object.fetch('name')}" }

          storage.bulk_delete_objects(keys)
        end
      end

      def exist?(key)
        instrument :exist, key: key do |payload|
          payload[:exist] = storage.show_object_metadata(key).is_a?(Net::HTTPOK)
          payload.fetch(:exist)
        end
      end

      # :reek:LongParameterList
      # :reek:UnusedParameters
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

      # :reek:LongParameterList
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

      # :reek:LongParameterList
      # :reek:UnusedParameters
      # rubocop:disable Metrics/LineLength
      def headers_for_direct_upload(key, filename:, content_type:, content_length:, checksum:)
        {}
      end
      # rubocop:enable Metrics/LineLength
      # rubocop:enable Lint/UnusedMethodArgument

      private

      def handle_errors
        return unless block_given?

        yield.tap do |request|
          raise ActiveStorage::IntegrityError if request.is_a?(
            Net::HTTPUnprocessableEntity
          )
        end
      end

      # Reads the file for the given key in chunks, yielding each to the block.
      def stream(key, chunk_size: 5.megabytes)
        blob = storage.show_object_metadata(key)
        offset = 0

        raise ActiveStorage::FileNotFoundError unless blob.present?

        while offset < Integer(blob.fetch('Content-Length'))
          yield storage.get_object_by_range(
            key, offset..(offset + chunk_size - 1)
          ).body
          offset += chunk_size
        end
      end
    end
  end
end
