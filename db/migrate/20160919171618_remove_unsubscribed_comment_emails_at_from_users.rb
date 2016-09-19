class RemoveUnsubscribedCommentEmailsAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :unsubscribed_comment_emails_at
  end
end
