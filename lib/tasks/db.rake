namespace :db do

  task :port => :environment do
    Legacy = Sequel.connect('postgres://localhost/coderwall_development')

    Protip.delete_all
    Legacy[:protips].each do |row|
      puts "Creating #{row[:title]}"
      Protip.create!(
        public_id: row[:public_id],
        title: row[:title],
        slug: row[:slug],
        body: row[:body],
        user_id: row[:user_id],
        score: row[:score],
        boost_factor: row[:boost_factor],
        featured_at: row[:featured_at],
        created_at: row[:created_at],
        updated_at: row[:updated_at]
      )
    end
  end

end
