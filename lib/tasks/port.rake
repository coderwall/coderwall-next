namespace :db do

  task port: [
    'db:port:users',
    'db:port:badges',
    'db:port:pictures',
    'db:port:protips',
    'db:port:comments',
    'db:port:teams',
    'db:port:likes',
    'db:port:counters',
    'db:clean:spam',
    'cache:score:recalculate']

  namespace :port do

    def port_data_since
      days  = ENV['since'].to_i
      days  = 7 if days == 0
      since = days.days.ago
      puts "Porting #{days} days ago"
      ["created_at > ? OR updated_at > ?", since, since]
    end

    task :connect => :environment do
      if hide_sql_out = Rails.env.development?
        ActiveRecord::Base.logger.level = Logger::INFO
      end
      LegacyRedis = Redis.new(url: ENV['LEGACY_REDIS_URL'])
      Legacy = Sequel.connect(ENV['LEGACY_DB_URL'])

      # Monkeypatch methods just for porting needs
      ActiveRecord::Base.class_eval do
        def self.find_or_initialize_by_id(id)
          where(id: id).first || new
        end

        def self.reset_pk_sequence
          case ActiveRecord::Base.connection.adapter_name
          when 'PostgreSQL'
            ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
          else
            raise "Task not implemented for this DB adapter"
          end
        end
      end
    end

    namespace :jobs do
      task :clear => :environment do
        Job.delete_all
      end
    end

    task :jobs => :connect do
      puts "Sourcing jobs: #{ENV['source']}"
      response = Faraday.get(ENV['source'])
      results  = JSON.parse(response.body)

      results.each do |data|
        next if data['company_logo'].blank? || ENV['COMPANY_BLACKLIST'].split(',').include?(data['company'])

        data['created_at'] = Time.parse(data['created_at'])
        data['role_type']  = data.delete('type')
        desc  = data.delete("description")
        url   = data.delete('url')
        found = URI.extract(data.delete("how_to_apply"), /http(s)?/).first
        data['source'] = found || url
        data['source'] = data['source'].chomp("apply")
        data['expires_at']   = 1.month.from_now
        data['author_name']  = 'Seed Script'
        data['author_email'] = 'support@coderwall.com'
        begin
          job = Job.create!(data)
          puts "Created: #{job.title}"
        rescue Exception => ex
          puts "Failed: #{data['title']} - #{ex.message}"
        end
      end
    end

    task :check => :connect do
      puts "legacy => ported"
      puts "Likes: #{Legacy[:likes].count} => #{Like.count}"
      puts "Comments: #{Legacy[:comments].count} => #{Comment.count}"
      puts "Protips: #{Legacy[:protips].count} => #{Protip.count}"
      puts "Badges: #{Legacy[:badges].count} => #{Badge.count}"
      puts "Users: #{Legacy[:users].count} => #{User.count}"
    end

    task :karma => :environment do
      User.find_each do |user|
        karma = user.badges.size * 10
        karma += Like.where(likable: user.comments).size - user.comments.size
        karma += Like.where(likable: user.protips).size - user.protips.size
        karma += user.protips.sum(:views_count) / 50
        karma = 1 if karma <= 0
        user.update_column(:karma, karma)
        puts "#{user.username}: #{karma}"
      end
    end

    task :pictures => :connect do
      Legacy[:pictures].each do |row|
        if row[:user_id]
          picture = Picture.find_or_initialize_by_id(row[:id])
          picture.attributes.keys.each do |key|
            picture[key] = row[key.to_sym]
          end
          picture.save!
        else
          puts "Skipped #{row[:id]} -> #{row.inspect}"
        end
      end
      Picture.reset_pk_sequence
    end

    task :comments => :connect do
      Comment.reset_pk_sequence
      not_ported = []
      Legacy[:comments].where(port_data_since).each do |row|
        if row[:comment].to_s.size >= 2
          comment = Comment.find_or_initialize_by_id(row[:id])
          comment.attributes.except(:comment).keys.each do |key|
            comment[key] = row[key.to_sym]
          end
          comment.body = row[:comment]
          if !comment.save
            not_ported << comment
          end
        end
      end
      Comment.reset_pk_sequence
      puts "Failed to port #{not_ported.size}"
    end

    task :teams => :connect do
      Team.reset_pk_sequence
      not_ported = []
      # .where(port_data_since)
      Legacy[:teams].each do |row|
        team = Team.find_or_initialize_by_id(row[:id])
        team.attributes.keys.each do |key|
          team[key] = row[key.to_sym]
        end

        team.color  = row[:branding]

        if row[:github_organization_name].present?
          team.github = row[:github_organization_name]
        end

        legacy_impressions_key = "team:#{row[:id]}:impressions"
        team.views_count = LegacyRedis.get(legacy_impressions_key).to_i

        if team.save
          puts "#{team.name} (#{team.views_count})"
        else
          not_ported << team
          puts "#{row[:name]} skipped #{team.errors.inspect}"
        end
      end
      Team.reset_pk_sequence
      puts "Failed to port #{not_ported.size}"
    end

    task :likes => :connect do
      Like.reset_pk_sequence
      Legacy[:likes].where(port_data_since).each do |row|
        like = Like.find_or_initialize_by_id(row[:id])
        like.attributes.keys.each do |key|
          # puts "#{key} #{row[key.to_sym]}"
          like[key] = row[key.to_sym]
        end
        if like.save
          puts like.id
        else
          puts "#{row[:id]} skipped #{like.errors.inspect}"
        end
      end
      Like.reset_pk_sequence
    end

    task :badges => :connect do
      Badge.reset_pk_sequence
      Legacy[:badges].where(port_data_since).each do |row|
        unless row[:badge_class_name].nil?
          if LEGACY_BADGES[row[:badge_class_name]].nil?
            raise row[:badge_class_name].inspect
          end
          puts "Importing #{row[:id]}"

          badge = Badge.find_or_initialize_by_id(row[:id])
          badge.user_id = row[:user_id]
          badge.created_at = row[:created_at]
          badge.updated_at = row[:updated_at]

          legacy_badge      = LEGACY_BADGES[row[:badge_class_name]]
          badge.name        = legacy_badge[0]
          badge.image_name  = legacy_badge[1]
          badge.description = legacy_badge[2]
          badge.why         = legacy_badge[3]
          badge.provider    = 'Coderwall'
          badge.save!
        end
      end
      Badge.reset_pk_sequence
    end

    task :users => :connect do
      User.reset_pk_sequence
      Legacy[:users].where(port_data_since).each do |row|
        puts row[:username]
        begin
          user = User.find_or_initialize_by_id(row[:id])
          user.attributes.keys.each do |key|
            user[key] = row[key.to_sym]
          end

          social_links = []
          social_links << "[LinkedIn](#{row[:linkedin_public_url]})" unless row[:linkedin_public_url].blank?
          social_links << "[Blog](#{row[:blog]})" unless row[:blog].blank?
          social_links << "[Bitbucket](https://bitbucket.org/#{row[:bitbucket]})" unless row[:bitbucket].blank?
          social_links << "[Codeplex](http://www.codeplex.com/site/users/view/#{row[:codeplex]})" unless row[:codeplex].blank?
          social_links << "[Dribbble](http://dribbble.com/#{row[:dribbble]})" unless row[:dribbble].blank?
          social_links << "[StackOverflow](http://stackoverflow.com/users/#{row[:stackoverflow]})" unless row[:stackoverflow].blank?
          social_links << "[Speakerdeck](http://speakerdeck.com/u/#{row[:speakerdeck]})" unless row[:speakerdeck].blank?
          social_links << "[Slideshare](http://www.slideshare.net/#{row[:slideshare]})" unless row[:slideshare].blank?
          if !social_links.empty?
            user.about = '' if user.about.nil?
            user.about << "\n\n\n#{social_links.join(' ')}\n\n"
          end
          user.karma    = (Legacy[:endorsements].where(endorsed_user_id: row[:id]).count + 1)
          user.password = SecureRandom.hex
          user.skills = Legacy[:skills].select(:name, :tokenized).where(
            deleted: false,
            user_id: row[:id]).collect{|row| row[:name]}

          if team = Legacy[:teams].where(id: row[:team_id]).collect.first
            user.company = team[:name]
          end


          Rails.logger.info "#{row[:username]} => #{row[:email]}"
          user.save!

        end
      end
      User.reset_pk_sequence
    end

    task :protips => :connect do
      Protip.reset_pk_sequence
      not_ported = []
      Legacy[:protips].where(port_data_since).each do |row|
        puts "#{row[:id]} : #{row[:public_id]} : #{row[:slug]}"
        protip = Protip.find_or_initialize_by_id(row[:id])
        protip.attributes.keys.each do |key|
          protip[key] = row[key.to_sym]
        end
        protip.public_id   = row[:public_id]
        protip.likes_count = (Legacy[:likes].where( likable_id: row[:id], likable_type: 'Protip').count + 1)
        protip.tags = Legacy[:tags].select(:name).join(:taggings, :tag_id => :id).where(
          taggable_id: row[:id],
          taggable_type: 'Protip'
        ).collect{|row| row[:name]}

        legacy_impressions_key = "protip:#{protip.public_id}:impressions"
        protip.views_count = LegacyRedis.get(legacy_impressions_key).to_i

        protip.flagged = row[:inappropriate].to_i > 0

        if protip.user.blank? || !protip.save
          not_ported << protip
        end
      end
      Protip.reset_pk_sequence
      puts "Failed to port #{not_ported.size}"
    end

    task :counters => :environment do
      Comment.where(port_data_since).find_each do |comment|
        puts comment.id
        Comment.reset_counters(comment.id, :likes)
      end
      Protip.where(port_data_since).find_each do |protip|
        puts protip.id
        Protip.reset_counters(protip.id, :likes)
      end
    end
  end
end
