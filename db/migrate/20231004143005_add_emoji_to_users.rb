class AddEmojiToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :emoji, :string
  end
end
