# frozen_string_literal: true

RSpec.describe User do
  include ActiveJob::TestHelper

  subject(:user) { described_class.new }

  let(:random_key) { 'xtapjjcjiudrlk3tmwyjgpuobabd' }

  before do
    # Fixed key so VCR cassettes won't grow.
    allow(ActiveStorage::Blob).to(
      receive(:generate_unique_secure_token).and_return(random_key)
    )
  end

  describe '#avatar', vcr: {
    cassette_name: 'dummy/user-avatar'
  } do
    subject(:avatar) { user.avatar }

    let(:user) { User.create }

    it { is_expected.not_to be_attached }

    context 'when attaching file' do
      let(:filename) { 'test.jpg' }
      let(:io) { file_fixture("images/#{filename}").open }

      it 'should be attached' do
        perform_enqueued_jobs do
          avatar.attach(io: io, filename: filename)
        end

        expect(avatar).to be_attached
      end
    end
  end
end
