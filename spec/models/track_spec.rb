require 'rails_helper'

RSpec.describe Track, type: :model do
  it 'has a valid factory' do
    expect(build(:track)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:artists) }
    it { is_expected.to have_and_belong_to_many(:playlists) }
    it { is_expected.to have_many(:album_tracks).dependent(:destroy) }
    it { is_expected.to have_many(:albums).through(:album_tracks) }
    it { is_expected.to belong_to(:medium).optional }
    it { is_expected.to have_many(:user_tracks).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_tracks) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '#artist_name' do
    it 'returns an array of artist names' do
      artist = create(:artist, name: 'Radiohead')
      track = create(:track)
      track.artists << artist
      expect(track.artist_name).to eq([ 'Radiohead' ])
    end

    it 'returns multiple artist names' do
      track = create(:track)
      track.artists << create(:artist, name: 'Artist A')
      track.artists << create(:artist, name: 'Artist B')
      expect(track.artist_name).to contain_exactly('Artist A', 'Artist B')
    end
  end

  describe '#album_title' do
    it 'returns an array of album titles' do
      album = create(:album, title: 'OK Computer')
      track = create(:track)
      create(:album_track, album: album, track: track)
      expect(track.album_title).to eq([ 'OK Computer' ])
    end

    it 'returns empty array when no albums' do
      track = build(:track)
      expect(track.album_title).to eq([])
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
