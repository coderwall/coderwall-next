namespace :db do

  task restore: [
    'db:download:generate',
    'db:download:latest',
    'db:drop',
    'db:create',
    'db:download:load',
    'db:download:clean',
    'db:migrate'
  ]

  namespace :download do
    def db_dump_file
      "coderwall-production.dump"
    end

    desc 'Create a production database backup'
    task :generate do
      Bundler.with_clean_env do
        cmd = "heroku pg:backups capture DATABASE_URL --app coderwall-next"
        sh(cmd)
      end
    end

    desc 'Download latest database backup'
    task :latest do
      unless File.exists?(db_dump_file)
        Bundler.with_clean_env do
          sh("curl `heroku pg:backups public-url --app coderwall-next` -o #{db_dump_file}")
        end
      end
    end

    desc 'Load local database backup into dev'
    task load: :environment do
      raise 'local dump not found' unless File.exists?(db_dump_file)
      puts 'Loading Production database locally'
      `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d coderwall-next_development #{db_dump_file}`
    end

    task :clean do
      `rm #{db_dump_file}`
    end
  end

end
