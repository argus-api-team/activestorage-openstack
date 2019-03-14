# frozen_string_literal: true

module Openstack
  # :reek:IrresponsibleModule
  class Client
    # :reek:IrresponsibleModule
    class Storage
      # Deletes object at the specified URI.
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
