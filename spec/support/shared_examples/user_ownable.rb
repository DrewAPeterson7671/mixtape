RSpec.shared_examples 'UserOwnable' do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'name uniqueness' do
    it 'prevents duplicate names for the same user' do
      create(described_class.model_name.singular, name: 'MyName', user: owner)
      duplicate = build(described_class.model_name.singular, name: 'MyName', user: owner)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'allows different users to have the same name' do
      create(described_class.model_name.singular, name: 'SharedName', user: owner)
      other = build(described_class.model_name.singular, name: 'SharedName', user: other_user)
      expect(other).to be_valid
    end
  end
end
