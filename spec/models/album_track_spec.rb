require 'rails_helper'

RSpec.describe AlbumTrack, type: :model do
  it 'has a valid factory' do
    expect(build(:album_track)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:album) }
    it { is_expected.to belong_to(:track) }
  end

  describe 'validations' do
    subject { create(:album_track) }

    it { is_expected.to validate_uniqueness_of(:album_id).scoped_to(:track_id) }
  end
end
