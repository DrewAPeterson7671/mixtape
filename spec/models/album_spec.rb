require 'rails_helper'

RSpec.describe Album, type: :model do
  it 'has a valid factory' do
    expect(build(:album)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:artists) }
    it { is_expected.to belong_to(:medium).optional }
    it { is_expected.to belong_to(:release_type).optional }
    it { is_expected.to have_many(:user_albums).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_albums) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_numericality_of(:year).only_integer.is_greater_than_or_equal_to(1500).is_less_than_or_equal_to(Date.current.year).allow_nil }
  end

  describe 'various_artists' do
    it 'defaults to false' do
      album = create(:album)
      expect(album.various_artists).to be false
    end
  end

  describe '#artist_name' do
    it 'returns array of artist names' do
      album = create(:album)
      artist1 = create(:artist)
      artist2 = create(:artist)
      album.artists << [artist1, artist2]

      expect(album.artist_name).to contain_exactly(artist1.name, artist2.name)
    end
  end

  describe '#release_type_name' do
    it 'returns release type name when present' do
      rt = create(:release_type, name: 'LP')
      album = build(:album, release_type: rt)
      expect(album.release_type_name).to eq('LP')
    end

    it 'returns nil when release type is absent' do
      album = build(:album, release_type: nil)
      expect(album.release_type_name).to be_nil
    end
  end

  describe '#medium_name' do
    it 'returns medium name when present' do
      medium = create(:medium, name: 'Vinyl')
      album = build(:album, medium: medium)
      expect(album.medium_name).to eq('Vinyl')
    end

    it 'returns nil when medium is absent' do
      album = build(:album, medium: nil)
      expect(album.medium_name).to be_nil
    end
  end

end
