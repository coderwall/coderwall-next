class AddMarketingListToUsers < ActiveRecord::Migration
  def change
    add_column :users, :marketing_list, :text
    add_column :users, :email_invalid_at, :datetime
  end
end
