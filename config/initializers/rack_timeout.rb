Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: ENV.fetch('RACK_TIMEOUT', 5).to_i
Rack::Timeout::Logger.logger = Rails.logger
Rack::Timeout::Logger.level = Logger::Severity::WARN
