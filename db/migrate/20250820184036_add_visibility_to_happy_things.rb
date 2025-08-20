class AddVisibilityToHappyThings < ActiveRecord::Migration[7.0]
  def change
    add_column :happy_things, :visibility, :string, default: 'public'
    add_index :happy_things, :visibility
  end
end
