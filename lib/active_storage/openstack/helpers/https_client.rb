# frozen_string_literal: true

module ActiveStorage
  module Openstack
    module Helpers
      # Prepares authentication request.
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
