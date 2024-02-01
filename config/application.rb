require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CoderwallNext
  class Application < Rails::Application
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    config.assets.precompile += %w(.png .svg)
    config.exceptions_app = self.routes
    config.encoding = 'utf-8'

    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
     {
       params: event.payload[:params].reject { |k| %w(controller action).include?(k) }
     }
    end

    config.log_tags = [:uuid]
    config.log_level = ENV['LOG_LEVEL'] || :debug

    config.middleware.delete ActiveRecord::Migration::CheckPending
  end
end
