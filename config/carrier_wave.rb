CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp')
  config.cache_dir = "#{Rails.root}/tmp/uploads"

  if Rails.env.test?
    config.enable_processing = false
    config.storage = :file
  elsif Rails.env.development?
    config.enable_processing = true
    config.storage = :file
  else
    config.enable_processing = true
    config.storage           = :fog
    config.fog_directory     = ENV['FOG_DIRECTORY']
    config.fog_attributes    = { 'Cache-Control' => "max-age=#{365.day.to_i}" }
    config.fog_credentials   = {
      provider: 'AWS',
      aws_access_key_id:      ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key:  ENV['AWS_SECRET_ACCESS_KEY']
    }
    # config.asset_host = proc do |file|
    #   identifier = ENV['FOG_DIRECTORY']
    #   "http://#{identifier}.cdn.rackspacecloud.com"
    # end
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
