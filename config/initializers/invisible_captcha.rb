InvisibleCaptcha.setup do |config|
  config.honeypots           = [
    :city,
    :description,
    :subtitle,
    :website,
    :zip,
  ]
  config.visual_honeypots    = false
  config.timestamp_threshold = 15
  config.timestamp_enabled   = true
end
