# frozen_string_literal: true

describe ActiveStorage::Service::OpenstackService do
  subject(:service) { described_class.new configurations }

  let(:service_name) { :openstack }
  let(:configurations) do
    {
      openstack: {
        service: 'Openstack',
        container: Rails.application.config.x.openstack.fetch(:container),
        authentication_url: Rails.application.config.x.openstack.fetch(:authentication_url),
        region: Rails.application.config.x.openstack.fetch(:region),
        credentials: {
          username: Rails.application.credentials.openstack.fetch(:username),
          api_key: Rails.application.credentials.openstack.fetch(:api_key),
          temporary_url_key: Rails.application.credentials.openstack.fetch(:temporary_url_key)
        }
      }
    }
  end

  describe '.configure' do
    subject(:configure) { described_class.configure(service_name, configurations) }

    it do
      is_expected.to be_an_instance_of(described_class)
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
      is_expected.to be_an_instance_of(described_class)
    end
  end
end
