RSpec.describe User do
  subject(:user) { described_class.new }

  xdescribe '#avatar' do
    subject(:avatar) { user.avatar }

    it { is_expected.not_to be_attached }

    context 'when attaching file' do
      let(:filename) { 'test.jpg' }
      let(:key) { "/fixtures/files/images/#{filename}" }
      let(:file) { file_fixture("images/#{filename}") }
      let(:checksum) { Digest::MD5.file(file).hexdigest }

      it 'should be attached' do
        avatar.attach(io: file, filename: filename)

        expect(avatar).to be_attached
      end
    end
  end
end
