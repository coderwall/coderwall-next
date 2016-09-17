class AddSubscribersToArticles < ActiveRecord::Migration
  def change
    add_column :protips, :subscribers, :int, array: true, default: [], null: false
  end
end
