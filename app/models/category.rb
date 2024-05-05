# frozen_string_literal: true

# Categories for HappyThings
class Category < ApplicationRecord
  has_many :happy_things
end
