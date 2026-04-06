require 'rails_helper'

RSpec.describe Phase, type: :model do
  it 'has a valid factory' do
    expect(build(:phase)).to be_valid
  end

  describe 'validations' do
    subject { create(:phase) }

    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
