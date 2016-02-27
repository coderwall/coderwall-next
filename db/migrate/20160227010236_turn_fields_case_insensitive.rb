class TurnFieldsCaseInsensitive < ActiveRecord::Migration
  def change
    enable_extension :citext
    change_column :users, :username, :citext
    change_column :users, :email, :citext
  end
end
