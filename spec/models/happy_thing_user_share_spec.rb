# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HappyThingUserShare, type: :model do
  describe 'associations' do
    it { should belong_to(:happy_thing) }
    it { should belong_to(:friend).class_name('User') }
  end
end
