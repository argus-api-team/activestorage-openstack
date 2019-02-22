# frozen_string_literal: true

require_relative '../../../../lib/active_storage/openstack/token'

describe ActiveStorage::Openstack::Token do
  subject(:token) do
    described_class.new username: username,
                        password: password,
                        url: url
  end

  let(:username) { Rails.application.credentials.openstack.fetch(:username) }
  let(:password) { Rails.application.credentials.openstack.fetch(:api_key) }
  let(:url) { Rails.application.config.x.openstack.fetch(:auth_url) }

  describe '#get', vcr: {
    cassette_name: 'lib/active_storage/openstack/token/get',
    record: :once
  } do
    subject(:get) { token.get }

    it { is_expected.not_to be_empty }
  end

  describe '#payload' do
    subject(:payload) { token.payload }

    it { is_expected.to include(username) }
    it { is_expected.to include(password) }
  end

  describe '#cache_key' do
    subject(:cache_key) { token.cache_key }

    it { is_expected.to eq("openstack/token-#{username}") }
  end
end
