require 'rails_helper'

RSpec.describe UserAlbum, type: :model do
  it 'has a valid factory' do
    expect(build(:user_album)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:album) }
    it { is_expected.to belong_to(:default_edition).class_name('Edition').optional }
    it { is_expected.to have_many(:user_album_genres).with_foreign_key(:album_id).dependent(:destroy) }
    it { is_expected.to have_many(:genres).through(:user_album_genres) }
    it { is_expected.to have_many(:user_album_tags).with_foreign_key(:album_id).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:user_album_tags) }
  end

  describe '#genre_name' do
    it 'returns genre names from the user-scoped association' do
      user_album = create(:user_album)
      genre_a = create(:genre, name: 'Rock')
      genre_b = create(:genre, name: 'Pop')
      create(:user_album_genre, user: user_album.user, album: user_album.album, genre: genre_a)
      create(:user_album_genre, user: user_album.user, album: user_album.album, genre: genre_b)

      expect(user_album.genre_name).to contain_exactly('Rock', 'Pop')
    end

    it 'returns empty array when no genres assigned' do
      user_album = create(:user_album)
      expect(user_album.genre_name).to eq([])
    end
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
