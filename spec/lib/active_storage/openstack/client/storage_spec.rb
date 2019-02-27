# frozen_string_literal: true

require 'digest'
require "#{APP_ROOT}/lib/active_storage/openstack/client"
require "#{APP_ROOT}/lib/active_storage/openstack/client/storage"

describe ActiveStorage::Openstack::Client::Storage do
  subject(:storage) do
    described_class.new authenticator: authenticator,
                        container: container,
                        region: region
  end

  let(:authenticator) do
    instance_double(ActiveStorage::Openstack::Client::Authenticator)
  end
  let(:container) { Rails.application.config.x.openstack.fetch(:container) }
  let(:region) { Rails.application.config.x.openstack.fetch(:region) }

  it { is_expected.to be_valid }

  context 'without authenticator' do
    let(:authenticator) { nil }

    it { is_expected.to be_invalid }
  end

  context 'without container' do
    let(:container) { nil }

    it { is_expected.to be_invalid }
  end

  context 'without region' do
    let(:region) { nil }

    it { is_expected.to be_invalid }
  end

  describe '#uri' do
    subject(:uri) { storage.uri }

    before do
      allow(authenticator).to receive(:cache).and_return(cache)
      allow(authenticator).to receive(:cache_key).and_return('cache_key')
    end

    let(:cache) { instance_double(ActiveSupport::Cache::Store, read: payload) }
    let(:payload) do
      file_fixture('json/authenticator/cached_payload.json').read
    end

    it { is_expected.to be_an_instance_of(URI::HTTPS) }
    it { expect(uri.to_s).to include(storage.region.downcase) }
    it { expect(uri.to_s).to include(storage.container) }
  end

  describe '#get_object', vcr: {
    cassette_name: 'lib/active_storage/openstack/storage/get_object',
    record: :once
  } do
    subject(:get_object) { storage.get_object(object_path) }

    before do
      authenticator.authenticate
    end

    let(:username) { Rails.application.credentials.openstack.fetch(:username) }
    let(:password) { Rails.application.credentials.openstack.fetch(:api_key) }
    let(:authenticator) do
      ActiveStorage::Openstack::Client::Authenticator.new username: username,
                                                          password: password
    end
    let(:filename) { 'test.jpg' }
    let(:object_path) { "/fixtures/files/images/#{filename}" }
    let(:file) { file_fixture("images/#{filename}") }
    let(:checksum_md5) { Digest::MD5.file(file).hexdigest }

    it 'gets the specified file' do
      expect(get_object.fetch('etag')).to eq(checksum_md5)
    end
  end

  describe '#put_object', vcr: {
    cassette_name: 'lib/active_storage/openstack/storage/put_object',
    record: :once
  } do
    subject(:put_object) { storage.put_object(file, object_path) }

    before do
      authenticator.authenticate
    end

    let(:username) { Rails.application.credentials.openstack.fetch(:username) }
    let(:password) { Rails.application.credentials.openstack.fetch(:api_key) }
    let(:authenticator) do
      ActiveStorage::Openstack::Client::Authenticator.new username: username,
                                                          password: password
    end
    let(:filename) { 'test.jpg' }
    let(:object_path) { "/fixtures/files/images/#{filename}" }
    let(:file) { file_fixture("images/#{filename}") }
    let(:checksum_md5) { Digest::MD5.file(file).hexdigest }

    it 'gets the specified file' do
      expect(put_object.fetch('etag')).to eq(checksum_md5)
    end
  end
end
