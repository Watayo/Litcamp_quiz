class Menters < ActiveRecord::Migration[5.2]
  def change
    create_table :menters do |t|
      t.string :name
      t.string :img
      t.text :question
      t.text :one
      t.text :two
      t.text :three
      t.text :four
      t.boolean :select, default: false
    end
  end
end
