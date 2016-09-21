class AddCommentUnsubscribedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unsubscribed_comment_emails_at, :datetime
  end
end
