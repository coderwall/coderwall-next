class AddForeignKeyBadgesUsers < ActiveRecord::Migration
  def change
    add_foreign_key :badges, :users
  end
end
