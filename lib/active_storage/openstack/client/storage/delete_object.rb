# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # Extracts the object store URL from cached payload mathing the
        # specified region.
        class DeleteObject
          attr_reader :uri

          def initialize(uri:)
            @uri = uri
          end

          def request
            Net::HTTP::Delete.new(uri)
          end
        end
        private_constant :DeleteObject
      end
    end
  end
end
