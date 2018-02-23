Rack::Timeout.service_timeout = ENV.fetch('RACK_TIMEOUT', 5).to_i
