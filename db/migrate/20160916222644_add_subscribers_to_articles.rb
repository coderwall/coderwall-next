class AddSubscribersToArticles < ActiveRecord::Migration
  def change
    add_column :protips, :subscribers, :int, array: true, default: [], null: false
    Protip.includes(:comments, :likes).find_each do |p|
      commentors = p.comments.map(&:user_id).uniq
      likers = p.likes.map(&:user_id).uniq
      subscribers = ([p.user_id] | commentors | likers)
      p.update_columns(subscribers: subscribers)
    end
  end
end
