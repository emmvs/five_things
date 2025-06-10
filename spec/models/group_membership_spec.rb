# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupMembership, type: :model do
  describe 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:friend).class_name('User') }
  end
end
