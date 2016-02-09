class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :likable_id, :user_id, :value
      t.string  :likable_type
      t.timestamps null: false
    end
  end
end
