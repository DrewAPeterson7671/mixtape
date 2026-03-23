require 'rails_helper'

RSpec.describe UserTrackGenre, type: :model do
  it 'has a valid factory' do
    expect(build(:user_track_genre)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:track) }
    it { is_expected.to belong_to(:genre) }
  end

  describe 'validations' do
    subject { build(:user_track_genre) }

    it { is_expected.to validate_uniqueness_of(:genre_id).scoped_to([ :user_id, :track_id ]) }
  end
end
