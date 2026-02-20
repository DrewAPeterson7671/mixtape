require 'rails_helper'

RSpec.describe UserArtist, type: :model do
  it 'has a valid factory' do
    expect(build(:user_artist)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to belong_to(:priority).optional }
    it { is_expected.to belong_to(:phase).optional }
  end

  describe 'validations' do
    subject { build(:user_artist) }

    it { is_expected.to validate_uniqueness_of(:artist_id).scoped_to(:user_id) }
    it { is_expected.to validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5).allow_nil }
  end

  describe '#priority_name' do
    it 'returns priority name when present' do
      priority = create(:priority, name: 'High')
      user_artist = build(:user_artist, priority: priority)
      expect(user_artist.priority_name).to eq('High')
    end

    it 'returns nil when priority is absent' do
      user_artist = build(:user_artist, priority: nil)
      expect(user_artist.priority_name).to be_nil
    end
  end

  describe '#phase_name' do
    it 'returns phase name when present' do
      phase = create(:phase, name: 'Discovery')
      user_artist = build(:user_artist, phase: phase)
      expect(user_artist.phase_name).to eq('Discovery')
    end

    it 'returns nil when phase is absent' do
      user_artist = build(:user_artist, phase: nil)
      expect(user_artist.phase_name).to be_nil
    end
  end
end
