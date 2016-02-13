class AddLikesCache < ActiveRecord::Migration
  def change
    add_column :comments, :likes_count, :integer, default: 0
  end
end
