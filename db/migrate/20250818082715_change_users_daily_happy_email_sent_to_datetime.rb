class ChangeUsersDailyHappyEmailSentToDatetime < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :daily_happy_email_sent, :boolean
    add_column :users, :daily_happy_email_sent, :datetime
  end
end
