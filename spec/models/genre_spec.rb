require 'rails_helper'

RSpec.describe Genre, type: :model do
  it 'has a valid factory' do
    expect(build(:genre)).to be_valid
  end

  it_behaves_like 'UserOwnable'

  describe 'associations' do
    it { is_expected.to have_many(:user_artist_genres).dependent(:destroy) }
    it { is_expected.to have_many(:user_album_genres).dependent(:destroy) }
    it { is_expected.to have_many(:user_track_genres).dependent(:destroy) }
  end
end
