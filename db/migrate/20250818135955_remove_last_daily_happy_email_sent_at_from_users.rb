# frozen_string_literal: true

class RemoveLastDailyHappyEmailSentAtFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :last_daily_happy_email_sent_at, :datetime
  end
end
