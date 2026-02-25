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
  end
end
