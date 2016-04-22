class AddPublishAttributesToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :expires_at, :datetime
    add_column :jobs, :stripe_token, :text

    add_index :jobs, :expires_at
  end
end
