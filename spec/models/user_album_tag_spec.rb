require 'rails_helper'

RSpec.describe UserAlbumTag, type: :model do
  it 'has a valid factory' do
    expect(build(:user_album_tag)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:album) }
    it { is_expected.to belong_to(:tag) }
  end

  describe 'validations' do
    subject { build(:user_album_tag) }

    it { is_expected.to validate_uniqueness_of(:tag_id).scoped_to([ :user_id, :album_id ]) }
  end
end
