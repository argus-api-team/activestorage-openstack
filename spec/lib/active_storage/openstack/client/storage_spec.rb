# frozen_string_literal: true

require 'digest'

describe ActiveStorage::Openstack::Client::Storage do
  cassette_path = 'lib/active_storage/openstack/storage'

  subject(:storage) do
    described_class.new authenticator: authenticator,
                        container: container,
                        region: region
  end

  let(:username) { Rails.application.credentials.openstack.fetch(:username) }
  let(:password) { Rails.application.credentials.openstack.fetch(:api_key) }
  let(:authenticator) do
    ActiveStorage::Openstack::Client::Authenticator.new username: username,
                                                        password: password
  end
  let(:container) { Rails.application.config.x.openstack.fetch(:container) }
  let(:region) { Rails.application.config.x.openstack.fetch(:region) }

  before do
    VCR.use_cassette(
      'lib/active_storage/openstack/authenticator/authenticate'
    ) do
      authenticator&.authenticate
    end
  end

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

    it { is_expected.to be_an_instance_of(URI::HTTPS) }
    it { expect(uri.to_s).to include(storage.region.downcase) }
    it { expect(uri.to_s).to include(storage.container) }
  end

  describe '#get_object', vcr: {
    cassette_name: "#{cassette_path}/get_object"
  } do
    subject(:get_object) { storage.get_object(key) }

    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }

    it { is_expected.to be_an_instance_of(Net::HTTPOK) }
  end

  describe '#put_object' do
    subject(:put_object) do
      storage.put_object(key, io, checksum: checksum)
    end

    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }
    let(:file) { file_fixture("images/#{filename}") }
    let(:io) { file.open }
    let(:checksum) { Digest::MD5.file(file).base64digest }

    it 'returns Created code', vcr: {
      cassette_name: "#{cassette_path}/put_object"
    } do
      expect(put_object).to be_an_instance_of(Net::HTTPCreated)
    end

    context 'when checksum fails', vcr: {
      cassette_name: "#{cassette_path}/put_object-bad_checksum"
    } do
      let(:checksum) { Digest::MD5.base64digest('bad_checksum') }

      it { is_expected.to be_an_instance_of(Net::HTTPUnprocessableEntity) }
    end
  end

  describe '#delete_object', vcr: {
    cassette_name: "#{cassette_path}/delete_object"
  } do
    subject(:delete_object) { storage.delete_object(key) }

    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }

    it { is_expected.to be_an_instance_of(Net::HTTPNoContent) }
  end

  describe '#show_object_metadata', vcr: {
    cassette_name: "#{cassette_path}/show_object_metadata"
  } do
    subject(:show_object_metadata) do
      storage.show_object_metadata(key)
    end

    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }

    it { is_expected.to be_an_instance_of(Net::HTTPOK) }

    context 'when file does not exist', vcr: {
      cassette_name: "#{cassette_path}/show_object_metadata-not_found"
    } do
      let(:key) { 'unknown_file.jpg' }

      it { is_expected.to be_an_instance_of(Net::HTTPNotFound) }
    end
  end

  describe '#list_objects', vcr: {
    cassette_name: "#{cassette_path}/list_objects"
  } do
    subject(:list_objects) do
      storage.list_objects(options)
    end

    let(:options) { {} }

    it { is_expected.to be_an_instance_of(Net::HTTPOK) }

    context 'with options', vcr: {
      cassette_name: "#{cassette_path}/list_objects-with_options"
    } do
      let(:options) do
        {
          limit: 1,
          prefix: 'fixtures'
        }
      end

      it { is_expected.to be_an_instance_of(Net::HTTPOK) }
    end
  end

  describe '#create_temporary_uri' do
    subject(:create_temporary_uri) do
      storage.create_temporary_uri(key, http_method)
    end

    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }
    let(:http_method) { 'GET' }

    it { is_expected.to be_an_instance_of(URI::HTTPS) }
  end

  describe '#temporary_url' do
    subject(:temporary_url) do
      storage.temporary_url(key, http_method, filename: filename)
    end

    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }
    let(:http_method) { 'GET' }

    it { is_expected.to be_an_instance_of(String) }
    it { is_expected.to include('temp_url_sig=') }
    it { is_expected.to match(/temp_url_expires=(?<timestamp>\d{10,})/) }
    it { is_expected.to include("filename=#{filename}") }
  end

  describe '#bulk_delete_objects', vcr: {
    cassette_name: "#{cassette_path}/bulk_delete_objects"
  } do
    subject(:bulk_delete_objects) { storage.bulk_delete_objects(keys) }

    let(:keys) do
      %W[
        /#{container}/fixtures/files/images/test.jpg
        /#{container}/fixtures/files/images/test.png
      ]
    end

    it { is_expected.to be_an_instance_of(Net::HTTPOK) }
    it 'deletes all keys' do
      body_as_json = JSON.parse(bulk_delete_objects.body)

      expect(body_as_json.fetch('Number Deleted')).to eql(keys.size)
    end
  end
end
