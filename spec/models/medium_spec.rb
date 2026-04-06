require 'rails_helper'

RSpec.describe Medium, type: :model do
  it 'has a valid factory' do
    expect(build(:medium)).to be_valid
  end

  describe 'validations' do
    subject { create(:medium) }

    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
