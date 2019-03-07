# frozen_string_literal: true

describe ActiveStorage::Service::Configurator do
  subject(:configurator) { described_class.new configurations }

  let(:configurations) { {} }

  describe '.build' do
    subject(:build) { described_class.build(service_name, configurations) }

    let(:service_name) { :openstack }

    context 'when non-existent service_name' do
      let(:configurations) { {} }

      it { expect { build }.to raise_error(RuntimeError) }
    end

    context 'with service name' do
      let(:configurations) do
        {
          service_name => {
            service: 'Openstack',
            container: 'container',
            authentication_url: 'https://auth.cloud.ovh.net/v3/auth/tokens',
            region: 'GRA3',
            credentials: {
              username: 'username',
              api_key: 'api_key',
              temporary_url_key: 'temporary_url_key'
            }
          }
        }
      end

      it do
        expect(build).to be_an_instance_of(
          ActiveStorage::Service::OpenstackService
        )
      end
    end

    context 'with lowercased service name' do
      let(:configurations) do
        {
          service_name => {
            service: 'openstack',
            container: 'container',
            authentication_url: 'https://auth.cloud.ovh.net/v3/auth/tokens',
            region: 'GRA3',
            credentials: {
              username: 'username',
              api_key: 'api_key',
              temporary_url_key: 'temporary_url_key'
            }
          }
        }
      end

      it do
        expect(build).to be_an_instance_of(
          ActiveStorage::Service::OpenstackService
        )
      end
    end
  end
end
