require 'rails_helper'

RSpec.describe Priority, type: :model do
  it 'has a valid factory' do
    expect(build(:priority)).to be_valid
  end

  describe 'validations' do
    subject { create(:priority) }

    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
