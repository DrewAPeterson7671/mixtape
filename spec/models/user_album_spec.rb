require 'rails_helper'

RSpec.describe UserAlbum, type: :model do
  it 'has a valid factory' do
    expect(build(:user_album)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:album) }
  end

  describe 'validations' do
    subject { build(:user_album) }

    it { is_expected.to validate_uniqueness_of(:album_id).scoped_to(:user_id) }
    it 'allows rating 1-5 or nil' do
      subject.rating = 3
      expect(subject).to be_valid
      subject.rating = nil
      expect(subject).to be_valid
    end

    it 'rejects rating outside 1-5' do
      subject.rating = 6
      expect(subject).not_to be_valid
      subject.rating = -1
      expect(subject).not_to be_valid
    end

    it 'normalizes rating 0 to nil' do
      subject.rating = 0
      subject.valid?
      expect(subject.rating).to be_nil
    end
  end
end
