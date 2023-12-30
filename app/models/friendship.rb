class Friendship < ApplicationRecord
  belongs_to :wanna_be_friend, class_name: 'User'
  belongs_to :friend, class_name: 'User'
  enum status: { open: 0, pending: 1, accepted: 2 }
end
