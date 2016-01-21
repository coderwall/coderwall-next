namespace :db do
  task :port => ['db:port:users', 'db:port:comments', 'db:port:protips']

  namespace :port do
    task :connect => :environment do
      Legacy = Sequel.connect('postgres://localhost/coderwall_development')
    end

    task :comments => :connect do
      Comment.delete_all
      Legacy[:comments].each do |row|
        comment = Comment.new
        comment.attributes.except(:comment).keys.each do |key|
          comment[key] = row[key.to_sym]
        end
        comment.body = row[:comment]
        comment.save!
      end
    end

    task :users => :connect do
      User.delete_all
      Legacy[:users].each do |row|
        begin
          user = User.new
          user.attributes.keys.each do |key|
            user[key] = row[key.to_sym]
          end
          user.password = SecureRandom.hex
          user.save!
        rescue Exception => ex
          puts "Skipping user #{row[:username]} #{ex.message}"
        end
      end
    end

    task :protips => :connect do
      Protip.delete_all
      Legacy[:protips].each do |row|
        protip = Protip.new
        protip.attributes.keys.each do |key|
          protip[key] = row[key.to_sym]
        end
        protip.save!
      end
    end

  end
end
