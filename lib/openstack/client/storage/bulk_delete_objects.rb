# frozen_string_literal: true

module Openstack
  # :reek:IrresponsibleModule
  class Client
    # :reek:IrresponsibleModule
    class Storage
      # Deletes objects in bulk.
      # More details here: https://docs.openstack.org/swift/latest/middleware.html#bulk-delete
      class BulkDeleteObjects
        attr_reader :uri, :keys

        def initialize(uri:, keys: [])
          @uri = uri
          @keys = keys
        end

        def request
          add_params
          Net::HTTP::Post.new(uri).tap do |request|
            request.add_field('Content-type', 'text/plain')
            request.add_field('Accept', 'application/json')
            request.body = keys.join("\n")
          end
        end

        private

        def add_params
          uri.query = URI.encode_www_form('bulk-delete' => nil)
        end
      end
      private_constant :BulkDeleteObjects
    end
  end
end
