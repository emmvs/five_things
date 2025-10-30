# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id             :bigint           not null, primary key
#  content        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  happy_thing_id :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_comments_on_happy_thing_id  (happy_thing_id)
#  index_comments_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (happy_thing_id => happy_things.id)
#  fk_rails_...  (user_id => users.id)
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :happy_thing

  validates :content, presence: true
end
