# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :happy_thing
end
