class CreateThings < ActiveRecord::Migration[7.0]
  def change
    create_table :things do |t|
      t.text :first
      t.text :second
      t.text :third
      t.text :forth
      t.text :fifth
      t.datetime :date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
