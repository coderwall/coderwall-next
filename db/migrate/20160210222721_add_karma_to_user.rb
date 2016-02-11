class AddKarmaToUser < ActiveRecord::Migration
  def change
    add_column :users, :karma, :integer, default: 1
  end
end
