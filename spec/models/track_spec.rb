require 'rails_helper'

RSpec.describe Track, type: :model do
  it 'has a valid factory' do
    expect(build(:track)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:playlists) }
    it { is_expected.to belong_to(:medium).optional }
    it { is_expected.to belong_to(:album).optional }
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to have_many(:user_tracks).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_tracks) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:artist) }
  end

  describe '#artist_name' do
    it 'returns the artist name' do
      artist = create(:artist, name: 'Radiohead')
      track = build(:track, artist: artist)
      expect(track.artist_name).to eq('Radiohead')
    end
  end

  describe '#album_title' do
    it 'returns album title when present' do
      album = create(:album, title: 'OK Computer')
      track = build(:track, album: album)
      expect(track.album_title).to eq('OK Computer')
    end

    it 'returns nil when album is absent' do
      track = build(:track, album: nil)
      expect(track.album_title).to be_nil
    end
  end

  describe '#medium_name' do
    it 'returns medium name when present' do
      medium = create(:medium, name: 'CD')
      track = build(:track, medium: medium)
      expect(track.medium_name).to eq('CD')
    end

    it 'returns nil when medium is absent' do
      track = build(:track, medium: nil)
      expect(track.medium_name).to be_nil
    end
  end
end
