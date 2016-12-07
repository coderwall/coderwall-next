class ChangeUsersLastIpFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :users, :last_ip, :string
  end
end
