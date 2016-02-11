namespace :db do
  task :port => ['db:port:users', 'db:port:comments', 'db:port:protips', 'db:port:teams', 'db:port:likes', 'db:port:badges']

  namespace :port do
    task :connect => :environment do
      Legacy = Sequel.connect(ENV['LEGACY_DB'] || 'postgres://localhost/coderwall_development')
    end

    task :comments => :connect do
      Comment.delete_all
      Legacy[:comments].each do |row|
        if row[:comment].to_s.size >= 2
          comment = Comment.new
          comment.attributes.except(:comment).keys.each do |key|
            comment[key] = row[key.to_sym]
          end
          comment.body = row[:comment]
          comment.save!
        end
      end
    end

    task :teams => :connect do

    end

    task :likes => :connect do
      Like.delete_all
      Legacy[:likes].each do |row|
        like = Like.new
        like.attributes.keys.each do |key|
          like[key] = row[key.to_sym]
        end
        like.save!
      end
    end

    task :badges => :connect do
      Badge.delete_all
      Legacy[:badges].each do |row|
        unless row[:badge_class_name].nil?
          badge = Badge.new
          badge.user_id = row[:user_id]
          badge.created_at = row[:created_at]
          badge.updated_at = row[:updated_at]

          legacy_badge      = LEGACY_BADGES[row[:badge_class_name]]

          if LEGACY_BADGES[row[:badge_class_name]].nil?
            raise row[:badge_class_name].to_s
          end

          badge.name        = legacy_badge[0]
          badge.image_name  = legacy_badge[1]
          badge.description = legacy_badge[2]
          badge.why         = legacy_badge[3]
          badge.provider    = 'Coderwall'
          badge.save!
        end
      end

    end

    task :users => :connect do
      User.delete_all
      Legacy[:users].each do |row|
        begin
          puts "#{row[:username]} : #{row[:email]}"
          user = User.new
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
          user.save!

        # rescue Exception => ex
        #   puts "Skipping user #{row[:username]} #{ex.message}"
        end
      end
    end

    task :protips => :connect do
      Protip.delete_all
      Legacy[:protips].each do |row|
        puts "#{row[:id]} : #{row[:public_id]} : #{row[:slug]}"
        protip = Protip.new
        protip.attributes.keys.each do |key|
          protip[key] = row[key.to_sym]
        end

        protip.likes_count = (Legacy[:Likes].where(
          likable_id: row[:id],
          likable_type: 'Protip').count + 1)
        protip.tags = Legacy[:tags].select(:name).join(:taggings, :tag_id => :id).where(
          taggable_id: row[:id],
          taggable_type: 'Protip'
        ).collect{|row| row[:name]}

        protip.save!
      end
    end

  end

  # rails r 'puts Badges.all.each{|b| puts "\"#{b.name}\" => [\"#{b.display_name}\", \"#{b.image_path.gsub("badges/", "")}\", \"#{b.description}\", \"#{b.for}\"],"  }'
  LEGACY_BADGES = {
    "Beaver" => ["Beaver", "beaver.png", "Have at least one original repo where go is the dominant language", "having at least one original repo where go is the dominant language."],
    "Beaver3" => ["Beaver 3", "beaver3.png", "Have at least three original repo where go is the dominant language", "having at least three original repo where go is the dominant language."],
    "Epidexipteryx" => ["Epidexipteryx", "epidexipteryx.png", "Have at least one original repo where C++ is the dominant language", "having at least one original repo where C++ is the dominant language."],
    "Epidexipteryx3" => ["Epidexipteryx 3", "epidexipteryx3.png", "Have at least three original repo where C++ is the dominant language", "having at least three original repo where C++ is the dominant language."],
    "Locust" => ["Desert Locust", "desertlocust.png", "Have at least one original repo where Erlang is the dominant language", "having at least one original repo where Erlang is the dominant language."],
    "Locust3" => ["Desert Locust 3", "desertlocust3.png", "Have at least three original repos where Erlang is the dominant language", "having at least three original repos where Erlang is the dominant language."],
    "Narwhal" => ["Narwhal", "narwhal.png", "Have at least one original repo where Clojure is the dominant language", "having at least one original repo where Clojure is the dominant language."],
    "Narwhal3" => ["Narwhal 3", "narwhal3.png", "Have at least three original repos where Clojure is the dominant language", "having at least three original repos where Clojure is the dominant language."],
    "Ashcat" => ["Ashcat", "moongoose-rails.png", "Make Ruby on Rails better for everyone by getting a commit accepted", "making Ruby on Rails better for everyone when your commit was accepted."],
    "Kona" => ["Kona", "coffee.png", "Have at least one original repo where CoffeeScript is the dominant language", "having at least one original repo where CoffeeScript is the dominant language."],
    "Raven" => ["Raven", "raven.png", "Have at least one original repo where some form of shell script is the dominant language", "having at least one original repo where some form of shell script is the dominant language."],
    "Labrador" => ["Lab", "labrador.png", "Have at least one original repo where C# is the dominant language", "having at least one original repo where C# is the dominant language."],
    "Labrador3" => ["Lab 3", "labrador3.png", "Have at least three original repos where C# is the dominant language", "having at least three original repos where C# is the dominant language."],
    "Trex" => ["T-Rex", "trex.png", "Have at least one original repo where C is the dominant language", "having at least one original repo where C is the dominant language."],
    "Trex3" => ["T-Rex 3", "trex3.png", "Have at least three original repos where C is the dominant language", "having at least three original repos where C is the dominant language."],
    "Honeybadger1" => ["Honey Badger", "honeybadger.png", "Have at least one original Node.js-specific repo", "having at least one original Node.js-specific repo."],
    "Honeybadger3" => ["Honey Badger 3", "honeybadger3.png", "Have at least three Node.js specific repos", "having at least three Node.js specific repos."],
    "Changelogd" => ["Changelog'd", "changelogd.png", "Have an original repo featured on the Changelog show", "having an original repo featured on the Changelog show."],
    "Bear" => ["Bear", "bear.png", "Have at least one original repo where Objective-C is the dominant language", "having at least one original repo where Objective-C is the dominant language."],
    "Bear3" => ["Bear 3", "bear3.png", "Have at least three original repos where Objective-C is the dominant language", "having at least three original repos where Objective-C is the dominant language."],
    "Cub" => ["Cub", "cub.png", "Have at least one original jQuery or Prototype open source repo", "having at least one original jQuery or Prototype open source repo."],
    "Mongoose" => ["Mongoose", "mongoose.png", "Have at least one original repo where Ruby is the dominant language", "having at least one original repo where Ruby is the dominant language."],
    "Mongoose3" => ["Mongoose 3", "mongoose3.png", "Have at least three original repos where Ruby is the dominant language", "having at least three original repos where Ruby is the dominant language."],
    "Railscamp" => ["Railscamp", "railscamp.png", "Attend at least one RailsCamp event anywhere in the world", "attending at least one RailsCamp event anywhere in the world."],
    "Python" => ["Python", "python.png", "Would you expect anything less? Have at least one original repo where Python is the dominant language", "having at least one original repo where Python is the dominant language."],
    "Python3" => ["Python 3", "python3.png", "Have at least three original repos where Python is the dominant language", "having at least three original repos where Python is the dominant language"],
    "Charity" => ["Charity", "charity.png", "Fork and commit to someone's open source project in need", "forking and commiting to someone's open source project."],
    "Forked" => ["Forked", "forked1.png", "Have a project valued enough to be forked by someone else", "having a project valued enough to be forked by someone else."],
    "Forked20" => ["Forked 20", "forked20.png", "Have an established project that's been forked at least 20 times", "having a project valued enough to be forked by at least 20 developers."],
    "Forked50" => ["Forked 50", "forked50.png", "Have a project with a thriving community of users that's been forked at least 50 times", "having a project valued enough to be forked by at least 50 developers."],
    "Forked100" => ["Forked 100", "forked100.png", "Have a seriously badass project that's been forked at least 100 times", "having a seriously badass project that's been forked at least 100 times."],
    "Lemmings1000" => ["Kilo of Lemmings", "1000lemming.png", "Establish a space in the open source hall of fame by getting at least 1000 devs to watch a project", "establishing a space in the open source hall of fame by getting at least 1000 devs to watch your project."],
    "Lemmings100" => ["Lemmings 100", "100lemming.png", "Write something great enough to have at least 100 watchers of the project", "writing something great enough to have at least 100 people following it."],
    "Altruist" => ["Altruist", "altrustic.png", "Increase developer well-being by sharing at least 20 open source projects", "increasing developer well-being by sharing at least 20 open source projects."],
    "Philanthropist" => ["Philanthropist", "philanthropist.png", "Truly improve developer quality of life by sharing at least 50 individual open source projects", "improving developers' quality of life by sharing at least 50 individual open source projects"],
    "Polygamous" => ["Walrus", "walrus.png", "The walrus is no stranger to variety. Use at least 4 different languages throughout all your repos", "using at least 4 different languages throughout your open source repos."],
    "EarlyAdopter" => ["Opabinia", "earlyadopter.png", "Started social coding on GitHub within 6 months of its first signs of life", "starting social coding on GitHub within 6 months of its first signs of life."],
    "Octopussy" => ["Octopussy", "octopussy.png", "Have a repo followed by a member of the GitHub team", "having a repo followed by a member of the GitHub team."],
    "Velociraptor3" => ["Velociraptor 3", "velociraptor3.png", "Have at least three original repos where Perl is the dominant language", "having at least three original repos where Perl is the dominant language"],
    "Velociraptor" => ["Velociraptor", "velociraptor.png", "Have at least one original repo where Perl is the dominant language", "having at least one original repo where Perl is the dominant language."],
    "NephilaKomaci3" => ["Nephila Komaci 3", "nephilakomaci3.png", "Have at least three original repos where PHP is the dominant language", "having at least three original repos where PHP is the dominant language."],
    "NephilaKomaci" => ["Nephila Komaci", "nephilakomaci.png", "Have at least one original repos where PHP is the dominant language", "having at least one original repos where PHP is the dominant language"],
    "Komododragon" => ["Komodo Dragon", "komododragon.png", "Have at least one original repo where Java is the dominant language", "having at least one original repo where Java is the dominant language."],
    "Komododragon3" => ["Komodo Dragon 3", "komododragon3.png", "Have at least three original repos where Java is the dominant language", "having at least three original repos where Java is the dominant language."],
    "Platypus" => ["Platypus", "platypus.png", "Have at least one original repo where scala is the dominant language", "having at least one original repo where scala is the dominant language."],
    "Platypus3" => ["Platypus 3", "platypus3.png", "Have at least three original repo where scala is the dominant language", "having at least three original repo where scala is the dominant language."],
    "Entrepreneur" => ["Entrepreneur", "entrepreneur.png", "Help build a product by contributing to an Assembly product", "working on an Assembly product when your commit was accepted."]
  }
end
