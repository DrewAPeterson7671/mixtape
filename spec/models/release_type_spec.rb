require 'rails_helper'

RSpec.describe ReleaseType, type: :model do
  it 'has a valid factory' do
    expect(build(:release_type)).to be_valid
  end

  describe 'validations' do
    subject { create(:release_type) }

    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
