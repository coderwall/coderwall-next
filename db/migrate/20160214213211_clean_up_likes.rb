class CleanUpLikes < ActiveRecord::Migration
  def change
    remove_column :likes, :value
    add_index :likes, [:user_id, :likable_type, :likable_id], :unique => true
  end
end
