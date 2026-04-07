RSpec.shared_examples 'UserOwnable' do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'scopes' do
    let!(:system_record) { create(described_class.model_name.singular, name: 'System One') }
    let!(:owned_record) { create(described_class.model_name.singular, name: 'User One', user: owner) }
    let!(:other_record) { create(described_class.model_name.singular, name: 'Other One', user: other_user) }

    describe '.visible_to' do
      it 'returns system records and own records' do
        result = described_class.visible_to(owner)
        expect(result).to include(system_record, owned_record)
        expect(result).not_to include(other_record)
      end
    end

    describe '.system_records' do
      it 'returns only records with nil user_id' do
        expect(described_class.system_records).to include(system_record)
        expect(described_class.system_records).not_to include(owned_record, other_record)
      end
    end

    describe '.owned_by' do
      it 'returns only records owned by the given user' do
        expect(described_class.owned_by(owner)).to include(owned_record)
        expect(described_class.owned_by(owner)).not_to include(system_record, other_record)
      end
    end
  end

  describe '#system?' do
    it 'returns true for system records' do
      record = build(described_class.model_name.singular, user: nil)
      expect(record.system?).to be true
    end

    it 'returns false for user records' do
      record = build(described_class.model_name.singular, user: owner)
      expect(record.system?).to be false
    end
  end

  describe '#owned_by?' do
    it 'returns true for records owned by the given user' do
      record = build(described_class.model_name.singular, user: owner)
      expect(record.owned_by?(owner)).to be true
    end

    it 'returns false for records owned by a different user' do
      record = build(described_class.model_name.singular, user: owner)
      expect(record.owned_by?(other_user)).to be false
    end
  end

  describe 'name uniqueness within visible set' do
    it 'prevents duplicate system record names' do
      create(described_class.model_name.singular, name: 'Taken', user: nil)
      duplicate = build(described_class.model_name.singular, name: 'Taken', user: nil)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'prevents user from creating a name that exists as system' do
      create(described_class.model_name.singular, name: 'SystemName', user: nil)
      duplicate = build(described_class.model_name.singular, name: 'SystemName', user: owner)
      expect(duplicate).not_to be_valid
    end

    it 'prevents user from creating a duplicate of their own name' do
      create(described_class.model_name.singular, name: 'MyName', user: owner)
      duplicate = build(described_class.model_name.singular, name: 'MyName', user: owner)
      expect(duplicate).not_to be_valid
    end

    it 'allows different users to have the same name' do
      create(described_class.model_name.singular, name: 'SharedName', user: owner)
      other = build(described_class.model_name.singular, name: 'SharedName', user: other_user)
      expect(other).to be_valid
    end
  end
end
