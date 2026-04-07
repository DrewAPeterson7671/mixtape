require 'rails_helper'

RSpec.describe Tag, type: :model do
  it 'has a valid factory' do
    expect(build(:tag)).to be_valid
  end

  it_behaves_like 'UserOwnable'

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:playlists) }
    it { is_expected.to have_many(:user_artist_tags).dependent(:destroy) }
    it { is_expected.to have_many(:user_album_tags).dependent(:destroy) }
    it { is_expected.to have_many(:user_track_tags).dependent(:destroy) }
  end
end
