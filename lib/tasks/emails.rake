namespace :emails do
  task :cleanup => :environment do
    popular = Protip.where("created_at < ? AND array_length(subscribers, 1) > ?", 1.year.ago, 5).all
    popular.each do |protip|
      subscribers = []
      subscribers << protip.user.id
      protip.comments.where("created_at > ?", 1.year.ago).each do |author|
        subscribers << author.id
      end

      Protip.where(id: protip.id).update_all(subscribers: subscribers)
      protip.reload
      puts "#{protip.public_id} => #{protip.subscribers.size}"
    end
  end

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
