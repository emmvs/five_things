# frozen_string_literal: true

# == Schema Information
#
# Table name: happy_thing_user_shares
#
#  id              :bigint           not null, primary key
#  happy_thing_id  :bigint           not null
#  friend_id       :bigint           not null (User)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class HappyThingUserShare < ApplicationRecord
  belongs_to :happy_thing
  belongs_to :friend, class_name: 'User'
end
