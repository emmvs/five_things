# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:group_memberships).dependent(:destroy) }
    it { should have_many(:friends).through(:group_memberships) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
