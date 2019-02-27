# frozen_string_literal: true

module ActiveStorage
  module Openstack
    module Helpers
      # Enables SSL mode for the specified uri.
      module HTTPSClient
        def https_client
          Net::HTTP.new(uri.host, uri.port).tap do |client|
            client.use_ssl = true
            client.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end
      end
    end
  end
end
