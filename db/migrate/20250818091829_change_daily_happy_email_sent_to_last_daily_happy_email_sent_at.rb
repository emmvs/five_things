class ChangeDailyHappyEmailSentToLastDailyHappyEmailSentAt < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :daily_happy_email_sent, :last_daily_happy_email_sent_at
  end
end
