require 'rails_helper'

RSpec.describe ReleaseType, type: :model do
  it 'has a valid factory' do
    expect(build(:release_type)).to be_valid
  end

  it_behaves_like 'UserOwnable'
end
