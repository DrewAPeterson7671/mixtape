require 'rails_helper'

RSpec.describe Artist, type: :model do
  it 'has a valid factory' do
    expect(build(:artist)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:albums) }
    it { is_expected.to have_and_belong_to_many(:tracks) }
    it { is_expected.to have_and_belong_to_many(:playlists) }
    it { is_expected.to have_many(:user_artists).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_artists) }
  end

  describe 'validations' do
    subject { build(:artist) }

    it 'validates uniqueness of name' do
      create(:artist, name: 'Radiohead')
      duplicate = build(:artist, name: 'Radiohead')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end
  end
end
