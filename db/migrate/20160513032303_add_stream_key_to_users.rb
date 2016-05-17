class AddStreamKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stream_key, :text

    add_index :users, :stream_key, unique: true
  end
end
