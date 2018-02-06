namespace :spam do
  task :sweep => :environment do
    since = 30.days.ago

    protips = Protip.where('created_at > ?', since).where(bad_content: false); nil
    good_protips = []
    protips.each do |p|
      flags = Spaminator.new.protip_flags(p)
      if flags.any?
        Rails.logger.debug "#{p.id} – #{p.title} – #{p.body[0..100].gsub("\n", '')}"
        Rails.logger.debug "#{flags.inspect}" if flags.any?
        Rails.logger.debug

        p.bad_content = true
        p.user.bad_user = true
        p.save
      else
        good_protips << "https://coderwall.com/p/#{p.public_id} – #{p.title}"
      end
    end; nil

    good_users = []
    users = User.where('created_at > ?', since).where(bad_user: false); nil
    users.each do |u|
      flags = Spaminator.new.user_flags(u)
      if flags.any?
        Rails.logger.debug "#{u.id} – #{u.username} – #{(u.about || '')[0..100].gsub("\n", '')}"
        Rails.logger.debug "#{flags.inspect}" if flags.any?
        Rails.logger.debug

        u.bad_user!
      else
        good_users << "https://coderwall.com/#{u.username}"
      end
    end; nil

    ["Good Users", good_users, "Good Protips", good_protips].flatten.each do |e|
      Rails.logger.debug e
    end

    Rails.logger.info("spam-sweep bad-users=#{users.size - good_users.size}/#{users.size} bad-protips=#{protips.size - good_protips.size}/#{protips.size}")
  end
end