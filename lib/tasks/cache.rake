namespace :cache do

  task :clear => :environment do
    Rails.cache.clear
  end

  namespace :score do
    task :recalculate => :environment do
      ActiveRecord::Base.logger.level = Logger::INFO #hide sql output
      Protip.order(created_at: :asc).find_each(batch_size: 100) do |p|
        score = p.calculate_score
        p.update_column(:score, score)
        sleep 0.1
      end
    end
  end
end
