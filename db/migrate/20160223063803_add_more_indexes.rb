class AddMoreIndexes < ActiveRecord::Migration
  def change
    add_index :comments, :user_id,    unique: false
    add_index :protips,  :user_id,    unique: false
    add_index :protips,  :created_at, unique: false
  end
end
