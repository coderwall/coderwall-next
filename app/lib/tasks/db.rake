namespace :db do
  desc 'Quiet ActiveRecord!'
  task :mute => :environment do
    ActiveRecord::Base.logger = nil
  end
end
