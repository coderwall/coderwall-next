module ReverseMarkdown
  module Converters
    def self.reset!
      @@converters = {}
    end
  end
end

namespace :db do
  namespace :clean do

    #doesnt work yet
    task :markdown => :environment do
      ReverseMarkdown.config do |config|
        config.unknown_tags     = :bypass
        config.github_flavored  = false
        config.tag_border  = ''
      end

      ReverseMarkdown::Converters.reset!
      ReverseMarkdown::Converters.register :pre, ReverseMarkdown::Converters::Pre.new

      # _eefna
      protip = Protip.find_by_public_id('_eefna') #sujd_w
      puts protip.public_id

      root           = Nokogiri::HTML(protip.body).root
      converted_down = ReverseMarkdown::Converters.lookup(root.name).convert(root)

      protip.update_column(:body, converted_down)
    end

    task :tags => :environment do
      Protip.find_each do |protip|
        normalized_tags = protip.tags.compact.collect(&:downcase).collect{|t| t.sub(/^#/, '') }.uniq
        clean_tags = normalized_tags - [protip.user.username.downcase]
        puts "#{protip.public_id}: #{clean_tags.join(', ')}"
        protip.update_column(:tags, clean_tags)
      end
    end

    task :spam => :environment do
      usernames = %w{akashseo966 salokye Agus_pamungkasS 119harsh miss_shad Jaychowdhury robinburney laomayi Applecomputing happygoodmorni4 robinburney jstarun payalmlhotra Goyllo kevintrujillo jstarun vatsalyametal JaiLiners bollyshowbiz herobayan ayatali BrajbihariG prakashhhh1994 Guum5 sanjeevnitoday sanjeevnitoday}
      usernames << "Bastille day "

      spammers = User.where(username: usernames).all

      spammers = spammers + Protip.spam.collect(&:user)

      spammers = spammers + User.where("banned_at IS NOT NULL").all

      if protip = Protip.find_by_public_id(clash_of_clans_spam = '3tzscq')
        spammers = spammers + protip.comments.collect(&:user)
        protip.update_column(:bad_content, true)
      end

      spammers.uniq!

      puts "Found #{spammers.count} spammers"
      spammers.each do |spammer|
        puts "Destroying: #{spammer.username}"
        spammer.destroy
      end
    end

    task :orphans => :environment do
      [Comment, Protip, Like].each do |klass|
        count = klass.where("user_id NOT IN (select id from users)").count
        puts "#{klass}: deleting #{count} orphans"
        puts klass.where("user_id NOT IN (select id from users)").delete_all
      end
    end

    task :duplicates => :environment do
      puts "Badges#count prior cleaning duplicates: #{Badge.count}"
      Badge.connection.execute('
      DELETE FROM badges a USING (
        SELECT MIN(ctid) as ctid, user_id, name, created_at FROM badges
        GROUP BY user_id, name, created_at HAVING COUNT(*) > 1
      ) b
      WHERE
        a.user_id = b.user_id AND
        a.name    = b.name    AND
        a.user_id = b.user_id AND
        a.ctid <> b.ctid
      ')
      puts "Badges#count post cleaning duplicates: #{Badge.count}"
    end

    task :data => :environment do
      Like.delete_all
      Comment.delete_all
      Protip.delete_all
      Badge.delete_all
      User.delete_all
    end
  end
end
