# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.paths << Rails.root.join("app", "assets", "webpack")
Rails.application.config.assets.precompile += %w( minimal.css live-banner.jpg happy-cat.jpg conference-room.png offline-holder.png server-bundle.js)
Rails.application.config.assets.compile = true

type = ENV["REACT_ON_RAILS_ENV"] == "HOT" ? "non_webpack" : "static"
Rails.application.config.assets.precompile += [
  "application_#{type}.js",
  "application_#{type}.css"
]

# suppress annoying asset 404s
if Rails.env.development?
  class ActionDispatch::DebugExceptions
    alias_method :old_log_error, :log_error
    def log_error(env, wrapper)
      if wrapper.exception.is_a?  ActionController::RoutingError
        return
      else
        old_log_error env, wrapper
      end
    end
  end
end
