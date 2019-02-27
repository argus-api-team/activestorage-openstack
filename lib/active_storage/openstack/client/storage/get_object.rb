# frozen_string_literal: true

require 'digest'
require 'mimemagic'

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # Extracts the object store URL from cached payload mathing the
        # specified region.
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
