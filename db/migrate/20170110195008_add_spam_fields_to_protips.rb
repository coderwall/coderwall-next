class AddSpamFieldsToProtips < ActiveRecord::Migration
  def change
    add_column :protips, :user_ip, :string
    add_column :protips, :user_agent, :string
    add_column :protips, :referrer, :string
  end
end
