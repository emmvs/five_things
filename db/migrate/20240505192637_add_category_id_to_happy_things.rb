class AddCategoryIdToHappyThings < ActiveRecord::Migration[7.0]
  def change
    add_reference :happy_things, :category, foreign_key: true
  end
end
