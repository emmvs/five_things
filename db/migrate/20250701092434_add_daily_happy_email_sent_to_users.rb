class AddDailyHappyEmailSentToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :daily_happy_email_sent, :boolean, default: false
  end
end
