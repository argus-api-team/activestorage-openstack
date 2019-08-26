# frozen_string_literal: true

describe ActiveStorage::Service::OpenstackService do
  cassette_path = 'lib/active_storage/service/openstack_service'

  subject(:service) { described_class.new configurations }

  let(:service_name) { :openstack }
  let(:configurations) do
    {
      openstack: {
        service: 'Openstack',
        container: Rails.application.config.x.openstack.fetch(:container),
        authentication_url: Rails.application.config.x.openstack
                                 .fetch(:authentication_url),
        region: Rails.application.config.x.openstack.fetch(:region),
        credentials: {
          username: Rails.application.credentials.openstack.fetch(:username),
          api_key: Rails.application.credentials.openstack.fetch(:api_key),
          temporary_url_key: Rails.application.credentials.openstack
                                  .fetch(:temporary_url_key)
        }
      }
    }
  end

  describe '.configure' do
    subject(:configure) do
      described_class.configure(service_name, configurations)
    end

    it do
      expect(configure).to be_an_instance_of(described_class)
    end
  end

  describe '.build' do
    subject(:build) do
      described_class.build(
        configurator: configurator, **configurations.fetch(service_name)
      )
    end

    let(:configurator) do
      ActiveStorage::Service::Configurator.new(
        configurations.fetch(service_name)
      )
    end

    it do
      expect(build).to be_an_instance_of(described_class)
    end
  end

  describe '#upload' do
    subject(:upload) do
      service.upload(key, io, checksum: checksum, **options)
    end

    let(:service) { described_class.configure(service_name, configurations) }
    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }
    let(:file) { file_fixture("images/#{filename}") }
    let(:io) { file.open }
    let(:checksum) { Digest::MD5.base64digest(file.read) }
    let(:options) { {} }

    context 'with valid checksum', vcr: {
      cassette_name: "#{cassette_path}/upload-succeeds",
      record: :new_episodes
    } do
      it 'uploads file successfully' do
        upload

        expect(service.download(key)).to eql(IO.binread(file))
      ensure
        service.delete(key)
      end
    end

    context 'with invalid checksum', vcr: {
      cassette_name: "#{cassette_path}/upload-fails",
      record: :new_episodes
    } do
      let(:checksum) { Digest::MD5.base64digest('corrupted file') }

      it { expect { upload }.to raise_error(ActiveStorage::IntegrityError) }
      # rubocop:disable RSpec/PredicateMatcher
      it { expect(service.exist?(key)).to be_falsy }
      # rubocop:enable RSpec/PredicateMatcher
    end
  end

  describe '#download' do
    subject(:download) { service.download(key) }

    let(:service) { described_class.configure(service_name, configurations) }
    let(:filename) { 'test.jpg' }
    let(:key) { "fixtures/files/images/#{filename}" }
    let(:file) { file_fixture("images/#{filename}") }
    let(:io) { file.open }
    let(:checksum) { Digest::MD5.base64digest(file.read) }
    let(:options) { {} }

    context 'when file exists', vcr: {
      cassette_name: "#{cassette_path}/download-exists",
      record: :new_episodes
    } do
      before do
        service.upload(key, io, checksum: checksum, **options)
      end

      it { expect(download).to eql(IO.binread(file)) }
    end

    context 'when file does not exist', vcr: {
      cassette_name: "#{cassette_path}/download-not_found",
      record: :new_episodes
    } do
      let(:key) { 'unknown.jpg' }

      it do
        expect { download }.to raise_error(ActiveStorage::FileNotFoundError)
      end
    end

    context 'when file in chunks', vcr: {
      cassette_name: "#{cassette_path}/download-chunks",
      record: :new_episodes
    } do
      let(:key) { 'test.jpg' }
      let(:expected_chunks) { ['a' * chunk_size, 'b'] }
      let(:actual_chunks) { [] }
      let(:chunk_size) { 5.megabytes }
      let(:io) { StringIO.new(expected_chunks.join) }
      let(:checksum) { Digest::MD5.base64digest(expected_chunks.join) }

      before do
        service.upload(key, io, checksum: checksum)
      end

      after do
        service.delete(key)
      end

      it 'downloads in chunks' do
        service.download(key) { |chunk| actual_chunks << chunk }

        expect(actual_chunks).to(
          eql(expected_chunks), 'Downloaded chunks did not match uploaded data'
        )
      end
    end

    context 'when file does not exist in chunks', vcr: {
      cassette_name: "#{cassette_path}/download-not_found_chunks",
      record: :new_episodes
    } do
      let(:key) { 'unknown.jpg' }

      it do
        expect { download {} }.to raise_error(ActiveStorage::FileNotFoundError)
      end
    end
  end

  describe '#download_chunk' do
    subject(:download_chunk) { service.download_chunk(key, range) }

    let(:service) { described_class.configure(service_name, configurations) }
    let(:key) { 'test.jpg' }
    let(:range) { 19..21 }

    context 'when file exist', vcr: {
      cassette_name: "#{cassette_path}/download_chunk-exist",
      record: :new_episodes
    } do
      let(:key) { 'test.jpg' }
      let(:data) { '0123456789' }
      let(:io) { StringIO.new(data) }
      let(:checksum) { Digest::MD5.base64digest(data) }
      let(:range) { 2..5 }

      before do
        service.upload(key, io, checksum: checksum)
      end

      it { expect(download_chunk).to eql('2345') }
    end

    context 'when file does not exist', vcr: {
      cassette_name: "#{cassette_path}/download_chunk-not_found",
      record: :new_episodes
    } do
      let(:key) { 'unknown.jpg' }

      it do
        expect { download_chunk }.to(
          raise_error(ActiveStorage::FileNotFoundError)
        )
      end
    end
  end

  describe '#delete' do
    subject(:delete) { service.delete(key) }

    let(:key) { 'test.jpg' }
    let(:service) { described_class.configure(service_name, configurations) }

    context 'when file does not exist', vcr: {
      cassette_name: "#{cassette_path}/delete",
      record: :new_episodes
    } do
      it { expect { delete }.not_to raise_error }
    end
  end

  describe '#delete_prefixed', vcr: {
    cassette_name: "#{cassette_path}/delete_prefixed",
    record: :new_episodes
  } do
    subject(:delete_prefixed) { service.delete_prefixed(prefix) }

    let(:prefix) { 'a/a/' }
    let(:service) { described_class.configure(service_name, configurations) }
    let(:filename) { 'test.jpg' }
    let(:file) { file_fixture("images/#{filename}") }
    let(:io) { file.open }

    before do
      service.upload('a/a/a', io)
      service.upload('a/a/b', io)
      service.upload('a/b/a', io)
      delete_prefixed
    end

    # rubocop:disable RSpec/PredicateMatcher
    it { expect(service.exist?('a/a/a')).to be_falsy }
    it { expect(service.exist?('a/a/b')).to be_falsy }
    it { expect(service.exist?('a/b/a')).to be_truthy }
    # rubocop:enable RSpec/PredicateMatcher
  end

  describe '#exist?' do
    subject(:exist?) { service.exist?(key) }

    let(:service) { described_class.configure(service_name, configurations) }
    let(:key) { 'test.jpg' }

    context 'when file exist', vcr: {
      cassette_name: "#{cassette_path}/exists",
      record: :new_episodes
    } do
      let(:filename) { 'test.jpg' }
      let(:key) { "fixtures/files/images/#{filename}" }
      let(:file) { file_fixture("images/#{filename}") }
      let(:io) { file.open }
      let(:checksum) { Digest::MD5.base64digest(file.read) }

      before do
        service.upload(key, io, checksum: checksum)
      end

      it { expect(exist?).to be_truthy }
      # rubocop:disable RSpec/PredicateMatcher
      it { expect(service.exist?(key + 'unknown')).to be_falsy }
      # rubocop:enable RSpec/PredicateMatcher
    end
  end
end
