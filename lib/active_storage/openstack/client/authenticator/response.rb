# frozen_string_literal: true

module ActiveStorage
  module Openstack
    class Client
      # :reek:IrresponsibleModule
      class Authenticator
        # Response simplifies interaction with the request response.
        class Response
          attr_reader :request

          delegate :code, :message, :body, to: :request

          def initialize(request)
            @request = request
          end

          def headers
            request.each_header.to_h
          end

          def token
            headers.dig('x-subject-token')
          end

          def expires_at
            Time.parse(body_as_hash.dig('token', 'expires_at'))
          rescue TypeError
            nil
          end

          def to_cache
            # We cache JSON rather than ruby object. Simple object.
            {
              'headers': headers,
              'token': token,
              'expires_at': expires_at,
              'code': Integer(code),
              'message': message,
              'body': body_as_hash
            }.to_json
          end

          private

          def body_as_hash
            JSON.parse(body)
          rescue JSON::ParserError
            {}
          end
        end
        private_constant :Response
      end
    end
  end
end
