# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :happy_thing
end
