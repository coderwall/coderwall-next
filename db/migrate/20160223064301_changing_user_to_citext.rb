class ChangingUserToCitext < ActiveRecord::Migration
  def change
    enable_extension :citext
    change_column :users, :email,    :citext
    change_column :users, :username, :citext
  end
end
