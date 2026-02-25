require 'rails_helper'

RSpec.describe Edition, type: :model do
  it 'has a valid factory' do
    expect(build(:edition)).to be_valid
  end
end
