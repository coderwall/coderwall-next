namespace :db do
  task :port => [
    'db:port:users',
    'db:port:badges',
    'db:port:protips',
    'db:port:comments',
    'db:port:teams',
    'db:port:likes',
    'db:fix_counters',
    'db:clean:spam',
    'cache:score:recalculate']

  task :fix_counters => :environment do
    Comment.find_each do |comment|
      puts comment.id
      Comment.reset_counters(comment.id, :likes)
    end
    Protip.find_each do |protip|
      puts protip.id
      Protip.reset_counters(protip.id, :likes)
    end
  end

  namespace :clean do
    task :spam => :environment do
      spammers = Protip.spam.collect(&:user)
      spammers.each do |spammer|
        puts "Destroying spammer: #{spammer.username}"
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

  namespace :port do
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

    task :comments => :connect do
      Comment.reset_pk_sequence
      Legacy[:comments].each do |row|
        if row[:comment].to_s.size >= 2
          comment = Comment.find_or_initialize_by_id(row[:id])
          comment.attributes.except(:comment).keys.each do |key|
            comment[key] = row[key.to_sym]
          end
          comment.body = row[:comment]
          comment.save!
        end
      end
      Comment.reset_pk_sequence
    end

    task :teams => :connect do

    end

    task :likes => :connect do
      Like.reset_pk_sequence
      Legacy[:likes].each do |row|
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
      Legacy[:badges].each do |row|
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

    def port_data_since
      ["created_at > ? OR updated_at > ?", 2.day.ago, 2.day.ago]
    end

    task :users => :connect do
      User.reset_pk_sequence
      Legacy[:users].where(port_since).each do |row|
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
      Legacy[:protips].each do |row|
        puts "#{row[:id]} : #{row[:public_id]} : #{row[:slug]}"
        protip = Protip.find_or_initialize_by_id(row[:id])
        protip.attributes.keys.each do |key|
          protip[key] = row[key.to_sym]
        end

        protip.likes_count = (Legacy[:likes].where( likable_id: row[:id], likable_type: 'Protip').count + 1)
        protip.tags = Legacy[:tags].select(:name).join(:taggings, :tag_id => :id).where(
          taggable_id: row[:id],
          taggable_type: 'Protip'
        ).collect{|row| row[:name]}

        legacy_impressions_key = "protip:#{protip.public_id}:impressions"
        protip.views_count = LegacyRedis.get(legacy_impressions_key).to_i

        protip.flagged = row[:inappropriate].to_i > 0

        protip.save!
      end
      Protip.reset_pk_sequence
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
    "Entrepreneur" => ["Entrepreneur", "entrepreneur.png", "Help build a product by contributing to an Assembly product", "working on an Assembly product when your commit was accepted."],
    "HackathonStanford" => ["Stanford Hackathon", 'hackathonStanford.png', "Participated in Stanford's premier Hackathon, organized by the ACM, SVI Hackspace and BASES.", "participating in Stanford's premier Hackathon, organized by the ACM, SVI Hackspace and BASES."],
    "WrocLover" => [
      'wroc_love.rb',
      'wrocloverb.png',
      "Attended the 2012 wroc_love.rb ruby conference.",
      "attending the 2012 wroc_love.rb ruby conference."
    ],
    "Neo4jContest::Participant" => [
      "Neo4j Challenger",
      'neo4j-challenge.png',
      "Participated in 2012 Neo4j Challenge",
      "participating in the 2012 Neo4j seed the cloud challenge."
    ],
    "Neo4jContest::Winner" => [
      "Neo4j Winner",
      'neo4j-winner.png',
      "Won the 2012 Neo4j Challenge",
      "winning the 2012 Neo4j seed the cloud challenge."
    ],
    "Hackathon" => [
      "Hackathon",
      'hackathon.png',
      "Participated in a hackathon.",
      "participating in a hackathon."
    ],
    "Railsberry" => [
      "Railsberry",
      'railsberry.png',
      "Attended the 2012 Railsberry conference.",
      "attending the 2012 Railsberry conference."
    ],
    "HackathonCmu" => [
      "CMU Hackathon",
      'hackathonCMU.png',
      "Participated in CMU's Hackathon, organized by ScottyLabs.",
      "participating in CMU's Hackathon, organized by ScottyLabs."
    ]
  }
  (2011...2016).each do |year|
    LEGACY_BADGES["NodeKnockout::Contender#{year}"] = [
      'KO Contender',
      "ko-contender-#{year}.png",
      "Participated in #{year} Node Knockout",
      "participating in #{year} Node Knockout."
    ]
    LEGACY_BADGES["NodeKnockout::Judge#{year}"] = [
      'KO Judge',
      "ko-judge-#{year}.png",
      "Official Judge of the #{year} Node Knockout",
      "judging the #{year} Node Knockout."
    ]
    LEGACY_BADGES["NodeKnockout::Champion#{year}"] = [
      'KO Champion',
      "ko-champion-#{year}.png",
      "Won first place in the #{year} Node Knockout",
      "winning first place in the #{year} Node Knockout."
    ]
    LEGACY_BADGES["NodeKnockout::BestDesign#{year}"] = [
      'KO Design',
      "ko-best-design-#{year}.png",
      "Won the best designed app in the #{year} Node Knockout",
      "winning the best designed app in the #{year} Node Knockout"
    ]
    LEGACY_BADGES["NodeKnockout::MostVotes#{year}"] = [
      'KO Popular',
      "ko-most-votes-#{year}.png",
      "Won the most votes in the #{year} Node Knockout",
      "winning the most votes in the #{year} Node Knockout"
    ]
    LEGACY_BADGES["NodeKnockout::MostUseful#{year}"] = [
      'KO Innovation',
      "ko-most-innovative-#{year}.png",
      "Won the most innovative app in the #{year} Node Knockout",
      "winning the most innovative app in the #{year} Node Knockout"
    ]
    LEGACY_BADGES["NodeKnockout::MostComplete#{year}"] = [
      'KO Complete',
      "ko-most-complete-#{year}.png",
      "Won the most complete app in the #{year} Node Knockout",
      "winning the most complete app in the #{year} Node Knockout"
    ]
    LEGACY_BADGES["NodeKnockout::MostInnovative#{year}"] = [
      'KO Innovation',
      "ko-most-innovative-#{year}.png",
      "Won the most innovative app in the #{year} Node Knockout",
      "winning the most innovative app in the #{year} Node Knockout"
    ],
    LEGACY_BADGES["GithubGameoffJudge#{year}"] = [
      'Github Gameoff Judge',
      "github-gameoff-judge-#{year}.png",
      "Was a judge in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
      "judging the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc"
    ]

    LEGACY_BADGES["GithubGameoffWinner#{year}"] = [
      'Github Gameoff Winner',
      "github-gameoff-winner-#{year}.png",
      "Won the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
      "winning the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc"
    ]

    LEGACY_BADGES["GithubGameoffRunnerUp#{year}"] = [
      'Github Gameoff Runner Up',
      "github-gameoff-runner-up-#{year}.png",
      "Was runner up in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
      "being the runner up in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc"
    ]

    LEGACY_BADGES["GithubGameoffHonorableMention#{year}"] = [
      'Github Gameoff Honorable Mention',
      "github-gameoff-honorable-mention-#{year}.png",
      "Was an honorable mention in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
      "being noted an honorable mention in the Github Gameoff #{year} building a game based on git concepts of forking, branching"
    ]
    LEGACY_BADGES["GithubGameoffParticipant#{year}"] = [
      'Github Gameoff Participant',
      "github-gameoff-participant-#{year}.png",
      "Participated in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
      "participating in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc"
    ]

    LEGACY_BADGES["TwentyFourPullRequestsParticipant#{year}"] = [
      "24PullRequests Participant",
      "24-participant.png",
      "Sent at least one pull request during the first 24 days of December #{year}",
      "participating in the 24pullrequest initiative during #{year}"
    ]

    LEGACY_BADGES["TwentyFourPullRequestsContinuous#{year}"] = [
      "24PullRequests Continuous Syncs",
      "24-continuous-sync.png",
      "Sent at least 24 pull requests during the first 24 days of December #{year}",
      "Sent at least 24 pull requests during the first 24 days of December #{year}"
    ]
  end
end
