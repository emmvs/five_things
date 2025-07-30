# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id             :bigint           not null, primary key
#  user_id        :bigint           not null
#  happy_thing_id :bigint           not null
#  content        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :happy_thing

  validates :content, presence: true
end
