require 'rails_helper'

RSpec.describe UserTrack, type: :model do
  it 'has a valid factory' do
    expect(build(:user_track)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:track) }
  end

  describe 'validations' do
    subject { build(:user_track) }

    it { is_expected.to validate_uniqueness_of(:track_id).scoped_to(:user_id) }
    it { is_expected.to validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5).allow_nil }
  end
end
