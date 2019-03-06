# frozen_string_literal: true

require 'digest'
require 'mimemagic'

module ActiveStorage
  module Openstack
    # :reek:IrresponsibleModule
    class Client
      # :reek:IrresponsibleModule
      class Storage
        # Uploads a file to the Object Store.
        # Checksum is validated after upload.
        class PutObject
          attr_reader :checksum, :io, :uri

          def initialize(io:, uri:, checksum: nil)
            @io = io
            @uri = uri
            @checksum = checksum
          end

          def request
            Net::HTTP::Put.new(uri).tap do |request|
              request.add_field('Content-Type', content_type)
              request.add_field('ETag', md5_checksum)
              request.body = io.read
            end
          end

          private

          def content_type
            Marcel::MimeType.for io,
                                 name: io.try(:original_filename),
                                 declared_type: io.try(:content_type)
          end

          def md5_checksum
            return checksum_to_hexdigest if checksum.present?

            Digest::MD5.file(io).hexdigest
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
