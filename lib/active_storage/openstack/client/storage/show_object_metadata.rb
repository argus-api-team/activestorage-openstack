# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # Shows the object metadata without downloading it.
        # Useful to check if object exists.
        class ShowObjectMetadata
          attr_reader :uri

          def initialize(uri:)
            @uri = uri
          end

          def request
            Net::HTTP::Head.new(uri)
          end
        end
        private_constant :ShowObjectMetadata
      end
    end
  end
end
