require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = User.new(first_name: 'Emma', email: 'emma@test.com', password: "123456")
    expect(user).to be_valid
  end
end
