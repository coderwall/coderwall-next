class AddForeignKeyCommentsProtips < ActiveRecord::Migration
  def change
    add_foreign_key :comments, :protips
  end
end
