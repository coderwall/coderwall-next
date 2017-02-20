class RemoveStreamKeyFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :stream_key
  end
end
