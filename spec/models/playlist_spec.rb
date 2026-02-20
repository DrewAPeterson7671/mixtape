require 'rails_helper'

RSpec.describe Playlist, type: :model do
  it 'has a valid factory' do
    expect(build(:playlist)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:artists) }
    it { is_expected.to have_and_belong_to_many(:tracks) }
    it { is_expected.to have_and_belong_to_many(:tags) }
    it { is_expected.to belong_to(:genre) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:playlist) }

    it { is_expected.to validate_presence_of(:name) }
    it 'validates uniqueness of name scoped to user' do
      user = create(:user)
      create(:playlist, name: 'My Playlist', user: user)
      duplicate = build(:playlist, name: 'My Playlist', user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end
    it { is_expected.to validate_presence_of(:platform) }
    it { is_expected.to validate_numericality_of(:year).only_integer.is_greater_than_or_equal_to(1500).is_less_than_or_equal_to(Date.current.year).allow_nil }
  end

  describe '#genre_name' do
    it 'returns the genre name' do
      genre = create(:genre, name: 'Rock')
      playlist = build(:playlist, genre: genre)
      expect(playlist.genre_name).to eq('Rock')
    end
  end
end
