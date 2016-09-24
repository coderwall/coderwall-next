namespace :partners do

  task :load => :environment do
    require 'csv'
    require 'open-uri'
    open("") do |file|
      CSV.parse(file, :headers => true) do |row|
        username = row[0]
        user = User.find_by_username(username)
        user.partner_asm_username         = row[1]
        user.partner_slack_username       = row[2]
        user.partner_email                = row[3]
        user.partner_last_contribution_at = Date.strptime(row[4], "%m/%d/%Y")
        user.partner_coins                = row[5]
        user.save!
      end
    end
  end

  task :update => :environment do
    flatten_to_latest(Github.user_pr_log).each do |username, contribution_date|
      if user = User.where(github: username).first
        user.partner_last_contribution_at = contribution_date
        user.save!
      end
    end
  end

  def flatten_to_latest(results)
    results.inject({}) do |users, row|
      user_id = row[:username]
      if users[user_id].blank? || users[user_id] < row[:created_at]
        users[user_id] = row[:created_at]
      end
      users
    end
  end

  task :email => :environment do
    User.where("partner_coins IS NOT NULL AND partner_last_contribution_at < ?", 1.year.ago).all.each do |user|
      UserMailer.partnership_expired(user).deliver_now!
    end
  end

  task :details => :environment do
    total = User.sum(:partner_coins).to_f
    puts "Current Partners: " + User.where("partner_coins IS NOT NULL AND partner_last_contribution_at >= ?", 1.year.ago).collect(&:username).join(', ')
    User.where("partner_coins IS NOT NULL AND partner_last_contribution_at < ?", 1.year.ago).all.collect do |user|
      puts "#{user.username}, #{user.partner_last_contribution_at} => #{user.ownership}%"
    end
  end

end
