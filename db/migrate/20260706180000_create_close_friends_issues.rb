# frozen_string_literal: true

class CreateCloseFriendsIssues < ActiveRecord::Migration[8.0]
  def change
    create_table :close_friends_issues do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.datetime :published_at
      t.datetime :sent_at
      t.references :created_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
