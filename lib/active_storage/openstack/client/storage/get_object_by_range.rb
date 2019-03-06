# frozen_string_literal: true

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # Downloads the object by chunks at the specified URI.
        # It uses the `Range` header with byte range.
        class GetObjectByRange < GetObject
          attr_reader :range

          def initialize(uri:, range:, options: {})
            super(uri: uri, options: options)
            @range = range
          end

          def request
            super.tap do |request|
              request.add_field('Range', byte_range) if range?
            end
          end

          private

          def range?
            range.present?
          end

          def byte_range
            "bytes=#{first_byte}-#{last_byte}"
          end

          def first_byte
            range.begin
          end

          def last_byte
            range.exclude_end? ? range_end - 1 : range_end
          end

          def range_end
            range.end
          end
        end
        private_constant :GetObjectByRange
      end
    end
  end
end
