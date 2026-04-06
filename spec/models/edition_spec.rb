require 'rails_helper'

RSpec.describe Edition, type: :model do
  it 'has a valid factory' do
    expect(build(:edition)).to be_valid
  end

  describe 'validations' do
    subject { create(:edition) }

    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
