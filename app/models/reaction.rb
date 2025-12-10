# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :happy_thing

  validates :emoji, presence: true
  validates :user_id, uniqueness: { scope: :happy_thing_id }
end
