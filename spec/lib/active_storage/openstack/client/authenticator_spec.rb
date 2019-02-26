# frozen_string_literal: true

require "#{APP_ROOT}/lib/active_storage/openstack/client/authenticator"

describe ActiveStorage::Openstack::Client::Authenticator do
  cassettes_path = 'lib/active_storage/openstack/authenticator'

  subject(:authenticator) do
    described_class.new username: username,
                        password: password
  end

  after do
    authenticator.cache.clear
  end

  let(:username) { Rails.application.credentials.openstack.fetch(:username) }
  let(:password) { Rails.application.credentials.openstack.fetch(:api_key) }

  it { is_expected.to be_valid }

  context 'without username' do
    let(:username) { nil }

    it { is_expected.to be_invalid }
  end

  context 'without password' do
    let(:password) { nil }

    it { is_expected.to be_invalid }
  end

  describe '#cache_key' do
    subject(:cache_key) { authenticator.cache_key }

    it { is_expected.to eq("openstack/token-#{username}") }
  end

  describe '#authenticate', vcr: {
    cassette_name: "#{cassettes_path}/authenticate",
    record: :once
  } do
    subject(:authenticate) { authenticator.authenticate }

    it { is_expected.to be_truthy }

    context 'with invalid credentials', vcr: {
      cassette_name: "#{cassettes_path}/authenticate-invalid",
      record: :once
    } do
      let(:password) { 'wrong_password' }

      it { is_expected.to be_falsy }
    end
  end

  describe '#token' do
    subject(:token) { authenticator.token }

    it { is_expected.to be_nil }

    context 'when authenticated', vcr: {
      cassette_name: "#{cassettes_path}/authenticate",
      record: :once
    } do
      before do
        authenticator.authenticate
      end

      it { is_expected.not_to be_nil }
    end
  end

  describe '#authenticate_request', vcr: {
    cassette_name: "#{cassettes_path}/authenticate",
    record: :once
  } do
    subject(:authenticate_request) do
      authenticator.authenticate_request { request }
    end

    let(:request) { Net::HTTP::Get.new(path) }
    let(:path) { '/' }

    it 'adds x-auth-token header' do
      authenticate_request

      headers_hash = request.each_header.to_h
      expect(headers_hash).to include('x-auth-token')
    end
  end
end
