class RemoveLoginCounts < ActiveRecord::Migration
  def change
    remove_column(:users, :login_count)
    remove_column(:users, :banned_at)    
  end
end
