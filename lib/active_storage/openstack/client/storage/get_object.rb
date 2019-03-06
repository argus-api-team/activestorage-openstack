# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # Downloads the object at the specified URI.
        class GetObject
          attr_reader :uri

          def initialize(uri:)
            @uri = uri
          end

          def request
            Net::HTTP::Get.new(uri)
          end
        end
        private_constant :GetObject
      end
    end
  end
end
