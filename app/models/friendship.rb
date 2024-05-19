# frozen_string_literal: true

# Friendship Model which makes sure a friendship is always either false or true (accepted)
class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }

  validates :accepted, inclusion: { in: [true, false] }
end
