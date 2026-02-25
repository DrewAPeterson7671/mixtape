require 'rails_helper'

RSpec.describe UserArtistGenre, type: :model do
  it 'has a valid factory' do
    expect(build(:user_artist_genre)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to belong_to(:genre) }
  end

  describe 'validations' do
    subject { build(:user_artist_genre) }

    it { is_expected.to validate_uniqueness_of(:genre_id).scoped_to([:user_id, :artist_id]) }
  end
end
