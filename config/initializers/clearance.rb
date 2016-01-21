# https://github.com/thoughtbot/clearance
Clearance.configure do |config|
  config.cookie_domain = '.coderall.com'
  config.httponly = false
  config.mailer_sender = "support@coderwall.com"
end
