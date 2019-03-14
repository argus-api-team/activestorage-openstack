# frozen_string_literal: true

module Openstack
  module Helpers
    # cache-friendly response body.
    module CacheableBody
      def body_to_cache
        # We cache JSON rather than ruby object. Simple object.
        {
          headers: headers,
          token: token,
          expires_at: expires_at,
          code: Integer(code),
          message: message,
          body: body_as_hash
        }.to_json
      end

      private

      def headers
        each_header.to_h
      end

      def token
        header.fetch('X-Subject-Token') { nil }
      end

      def expires_at
        Time.parse(body_as_hash.dig('token', 'expires_at'))
      rescue TypeError
        nil
      end

      def body_as_hash
        JSON.parse(body)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
