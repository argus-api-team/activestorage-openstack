# frozen_string_literal: true

require "#{APP_ROOT}/lib/active_storage/openstack/client"

describe ActiveStorage::Openstack::Client do
  subject(:client) do
    described_class.new username: username,
                        password: password
  end

  let(:username) { Rails.application.credentials.openstack.fetch(:username) }
  let(:password) { Rails.application.credentials.openstack.fetch(:api_key) }

  it { is_expected.to be_valid }
  it { is_expected.to delegate_method(:authenticate).to(:authenticator) }

  context 'without username' do
    let(:username) { nil }

    it { is_expected.to be_invalid }
  end

  context 'without password' do
    let(:password) { nil }

    it { is_expected.to be_invalid }
  end
end
