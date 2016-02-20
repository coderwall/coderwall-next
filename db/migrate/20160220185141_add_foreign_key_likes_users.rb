class AddForeignKeyLikesUsers < ActiveRecord::Migration
  def change
    add_foreign_key :likes, :users
  end
end
