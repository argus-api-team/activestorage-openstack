# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # Prepares authentication request.
      class HTTPSClient
        attr_reader :uri

        def initialize(uri:)
          @uri = uri
        end

        def client
          @client ||= Net::HTTP.new(uri.host, uri.port).tap do |client|
            client.use_ssl = true
            client.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end
      end
      private_constant :HTTPSClient
    end
  end
end
