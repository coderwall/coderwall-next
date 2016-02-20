class AddForeignKeyProtipsUsers < ActiveRecord::Migration
  def change
    add_foreign_key :protips, :users
  end
end
