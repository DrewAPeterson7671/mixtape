require 'rails_helper'

RSpec.describe Medium, type: :model do
  it 'has a valid factory' do
    expect(build(:medium)).to be_valid
  end

  it_behaves_like 'UserOwnable'
end
