# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = User.new(first_name: 'Emma', email: 'emma@test.com', password: '123456')
    expect(user).to be_valid
  end

  it 'validate that the password with scripts is not valid' do
    user = User.new(first_name: 'Emma', email: 'emma@test.com', password: '<script>123456</script>')
    expect(user).not_to be_valid
  end

  it 'is not valid with links in the name' do
    user = User.new(first_name: 'http://Emma', email: 'emma@test.com', password: '123456')
    expect(user).not_to be_valid
  end

  it 'is not valid with www. in the name' do
    user = User.new(first_name: 'www.pornhub.org', email: 'emma@test.com', password: '123456')
    expect(user).not_to be_valid
  end

  it 'is not valid with https in the name' do
    user = User.new(first_name: 'https://Emma', email: 'emma@test.com', password: '123456')
    expect(user).not_to be_valid
  end

  describe '#happy_streak' do
    let(:user) { create(:user) }

    context 'when there are no happy things' do
      it 'returns a streak of 0' do
        expect(user.happy_streak).to eq(0)
      end
    end

    context 'when there are consecutive happy things' do
      before do
        3.times { |n| create(:happy_thing, user:, start_time: 2.days.ago + n.days) }
      end

      it 'returns the correct streak count' do
        expect(user.happy_streak).to eq(3)
      end
    end

    context 'when happy things are not consecutive' do
      before do
        create(:happy_thing, user:, start_time: 3.days.ago)
        create(:happy_thing, user:, start_time: 1.day.ago)
      end

      it 'returns a streak ending at the first gap' do
        expect(user.happy_streak).to eq(1)
      end
    end
  end
end
