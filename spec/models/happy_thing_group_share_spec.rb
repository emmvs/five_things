# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HappyThingGroupShare, type: :model do
  it { should belong_to(:happy_thing) }
  it { should belong_to(:group) }
end
