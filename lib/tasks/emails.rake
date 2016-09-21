namespace :emails do
  task :send_comment_catchups => :environment do
    outbox = {}
    Comment.includes(:article).where('created_at > ?', 6.months.ago).find_each do |comment|
      comment.article.subscribers.each do |user_id|
        outbox[user_id] ||= []
        outbox[user_id] << comment if outbox[user_id].size < 3
      end
    end; nil

    User.where(id: outbox.keys).each do |u|
      comments = outbox[u.id]
      puts "#{u.email} #{comments.size}"

      comments.each do |c|
        puts "  #{c.id}"
        CommentMailer.new_comment(u, c).deliver_now!
      end
    end; nil
  end
end
