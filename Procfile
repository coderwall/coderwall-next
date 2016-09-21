web: bundle exec puma -C ./config/puma.rb --quiet
hot-assets: sh -c 'rm app/assets/webpack/* || true && HOT_RAILS_PORT=3500 npm run hot-assets'
rails-server-assets: sh -c 'npm run build:dev:server'
