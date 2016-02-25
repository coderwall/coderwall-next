class AddSimpleUserIdIndexOnLike < ActiveRecord::Migration
  def change
    add_index :likes, :user_id, unique: false
  end
end
