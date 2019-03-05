RSpec.describe User do
  subject(:user) { described_class.new }

  xdescribe '#avatar' do
    subject(:avatar) { user.avatar }

    it { is_expected.not_to be_attached }

    context 'when attaching file' do
      let(:filename) { 'test.jpg' }
      let(:io) { File.open(file_fixture("images/#{filename}")) }

      it 'should be attached' do
        avatar.attach(io: io, filename: filename)

        expect(avatar).to be_attached
      end
    end
  end
end
