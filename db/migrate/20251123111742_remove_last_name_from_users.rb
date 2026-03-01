class RemoveLastNameFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :last_name, :string
    rename_column :users, :first_name, :name
  end
end
