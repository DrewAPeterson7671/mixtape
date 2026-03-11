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
