# frozen_string_literal: true

require "#{APP_ROOT}/lib/active_storage/openstack/client/authenticator"

describe ActiveStorage::Openstack::Client::Authenticator do
  cassettes_path = 'lib/active_storage/openstack/authenticator'

  subject(:authenticator) do
    described_class.new username: username,
                        password: password
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

    after do
      authenticator.cache.clear
    end

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
  end
end
