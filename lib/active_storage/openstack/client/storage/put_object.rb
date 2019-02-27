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
        class PutObject
          attr_reader :checksum, :file, :uri

          def initialize(file:, uri:, checksum: nil)
            @file = file
            @uri = uri
            @checksum = checksum
          end

          def request
            Net::HTTP::Put.new(uri).tap do |request|
              request.add_field('Content-Type', content_type)
              request.add_field('ETag', md5_checksum)
              request.body = binary_file
            end
          end

          private

          def content_type
            MimeMagic.by_path(File.basename(file))
          end

          def md5_checksum
            return checksum if checksum.present?

            Digest::MD5.file(file).hexdigest
          end

          def binary_file
            IO.binread(file)
          end
        end
        private_constant :PutObject
      end
    end
  end
end
