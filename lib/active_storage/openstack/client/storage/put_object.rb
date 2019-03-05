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
            Marcel::MimeType.for file,
                                 name: file.try(:original_filename),
                                 declared_type: file.try(:content_type)
          end

          def md5_checksum
            return checksum_to_hexdigest if checksum.present?

            Digest::MD5.file(file).hexdigest
          end

          def binary_file
            IO.binread(file)
          end

          # ActiveStorage sends a `Digest::MD5.base64digest` checksum
          # OpenStack expects a `Digest::MD5.hexdigest` ETag
          def checksum_to_hexdigest
            checksum.unpack1('m0').unpack1('H*')
          end
        end
        private_constant :PutObject
      end
    end
  end
end
