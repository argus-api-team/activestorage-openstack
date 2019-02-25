# frozen_string_literal: true

require 'active_support/core_ext/securerandom'
require "#{APP_ROOT}/lib/active_storage/service/openstack_service"

describe ActiveStorage::Service::OpenstackService do
  subject(:service) { described_class.new }

  describe '#upload' do
    subject(:upload) do
      service.upload(key, io, checksum: checksum, **options)
    end

    let(:key) { SecureRandom.base58(24) }
    let(:data) { 'Some random string!' }
    let(:io) { StringIO.new(data) }
    let(:checksum) { Digest::MD5.base64digest(data) }
    let(:options) { {} }

    it 'uploads with integrity' do
      expect { upload }.to raise_error(NotImplementedError)
    end
  end
end
