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
      # rubocop:enable Lint/UnusedMethodArgument

      def download(key)
        instrument :download, key: key do
          storage.get_object(key)
        end
      end
    end
  end
end
