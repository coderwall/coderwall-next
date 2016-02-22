# https://github.com/thoughtbot/clearance
Clearance.configure do |config|
  config.httponly = true  #cookies only accessed from server
  config.routes   = false #disable clearance routes
  config.mailer_sender = "support@coderwall.com"
  config.cookie_expiration = ->(cookies){ 2.years.from_now.utc }

  if Rails.env.development?
    config.cookie_domain = 'localhost'
  elsif Rails.env.production?
    config.cookie_domain = '.coderwall.com'
    config.secure_cookie = true
  end

end
