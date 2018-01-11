namespace :spam do
  task :sweep => :environment do
    protips = Protip.where('created_at > ?', 7.days.ago).where(bad_content: false)
    good = []
    protips.each do |p|
      flags = Spaminator.new.protip_flags(p)
      if flags.any?
        puts "#{p.id} – #{p.title} – #{p.body[0..100].gsub("\n", '')}"
        puts "#{flags.inspect}" if flags.any?
        puts

        p.bad_content = true
        p.user.bad_user = true
        p.save
      else
        good << p
      end
    end

    users = User.where('created_at > ?', 7.days.ago).where(bad_user: false)
    users.map do |u|
      flags = Spaminator.new.user_flags(u)
      if flags.any?
        puts "#{u.id} – #{u.username} – #{(u.about || '')[0..100].gsub("\n", '')}"
        puts "#{flags.inspect}" if flags.any?
        puts

        u.bad_user!
      else
        good << u
      end
    end

    puts "Good"
    good.each do |e|
      puts "#{e.class}:#{e.id} – #{e.try(:username) || e.title}"
    end
  end
end