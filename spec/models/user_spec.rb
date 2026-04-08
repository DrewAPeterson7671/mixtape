require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:user_artists).dependent(:destroy) }
    it { is_expected.to have_many(:user_albums).dependent(:destroy) }
    it { is_expected.to have_many(:user_tracks).dependent(:destroy) }
    it { is_expected.to have_many(:playlists).dependent(:destroy) }
    it { is_expected.to have_many(:genres).dependent(:destroy) }
    it { is_expected.to have_many(:tags).dependent(:destroy) }
    it { is_expected.to have_many(:editions).dependent(:destroy) }
    it { is_expected.to have_many(:media).dependent(:destroy) }
    it { is_expected.to have_many(:phases).dependent(:destroy) }
    it { is_expected.to have_many(:priorities).dependent(:destroy) }
    it { is_expected.to have_many(:release_types).dependent(:destroy) }
  end

  describe '#seed_default_lookups' do
    it 'seeds default lookups on create' do
      user = create(:user, :with_default_lookups)

      expect(user.genres.count).to eq(15)
      expect(user.genres.pluck(:name)).to include('Rock', 'Jazz', 'Electronic')

      expect(user.media.count).to eq(5)
      expect(user.media.pluck(:name)).to include('CD', 'Vinyl', 'Digital')

      expect(user.release_types.count).to eq(7)
      expect(user.release_types.pluck(:name)).to include('LP', 'EP', 'Single')

      expect(user.editions.count).to eq(5)
      expect(user.editions.pluck(:name)).to include('Standard', 'Deluxe')

      expect(user.phases.count).to eq(4)
      expect(user.phases.pluck(:name)).to include('Discovery', 'Complete')

      expect(user.priorities.count).to eq(4)
      expect(user.priorities.pluck(:name)).to include('High', 'Low')

      expect(user.tags.count).to eq(0)
    end
  end
end
