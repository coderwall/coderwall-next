namespace :cache do

  task :clear => :environment do
    Rails.cache.clear
  end

  namespace :score do
    task :recalulate => :environment do
      ActiveRecord::Base.logger.level = Logger::INFO #hide sql output
      Protip.order(created_at: :asc).find_each do |p|
        score = p.cacluate_score        
        p.update_column(:score, score)
      end
    end
  end
end
