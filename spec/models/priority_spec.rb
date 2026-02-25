require 'rails_helper'

RSpec.describe Priority, type: :model do
  it 'has a valid factory' do
    expect(build(:priority)).to be_valid
  end
end
