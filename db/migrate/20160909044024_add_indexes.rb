class AddIndexes < ActiveRecord::Migration
  def change
    add_index :protips, :views_count
    add_index :users, :receive_newsletter
    add_index :users, :marketing_list
    add_index :users, :email_invalid_at
  end
end
