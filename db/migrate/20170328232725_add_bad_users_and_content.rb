class AddBadUsersAndContent < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :bad_user, :bool, null: false, default: false
    add_column :comments, :bad_content, :bool, null: false, default: false
    rename_column :protips, :flagged, :bad_content

    add_index :users, :bad_user
    add_index :protips, :bad_content
    add_index :comments, :bad_content
  end
end
