# frozen_string_literal: true

class AddCategoryIdToHappyThings < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_reference :happy_things, :category, foreign_key: true
  end
end
