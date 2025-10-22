# frozen_string_literal: true

# == Schema Information
#
# Table name: daily_happy_email_deliveries
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  recipient_id :bigint           not null
#  delivered_at :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class DailyHappyEmailDelivery < ApplicationRecord
  belongs_to :user
  belongs_to :recipient, class_name: 'User'

  validates :delivered_at, presence: true
end
