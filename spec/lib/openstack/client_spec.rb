# frozen_string_literal: true

describe Openstack::Client do
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

  describe '#authenticator' do
    subject(:authenticator) { client.authenticator }

    it do
      expect(authenticator).to an_instance_of(
        Openstack::Client::Authenticator
      )
    end
  end

  describe '#storage' do
    subject(:storage) { client.storage(container: container, region: region) }

    let(:container) { Rails.application.config.x.openstack.fetch(:container) }
    let(:region) { Rails.application.config.x.openstack.fetch(:region) }

    it do
      expect(storage).to an_instance_of(
        Openstack::Client::Storage
      )
    end
  end
end
