# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # List objects at the specified URI.
        # Generally a container is specified.
        # The `prefix=` url variable filters the list retrieved.
        class ListObjects
          attr_reader :uri, :options

          def initialize(uri:, options: {})
            @uri = uri
            @options = options
          end

          def request
            add_params
            Net::HTTP::Get.new(uri)
          end

          private

          def add_params
            uri.query = URI.encode_www_form(options)
          end
        end
        private_constant :ListObjects
      end
    end
  end
end
