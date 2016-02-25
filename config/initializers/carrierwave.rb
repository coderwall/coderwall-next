CarrierWave.configure do |config|
  if Rails.env.test?
    config.enable_processing = false
    config.storage           = :file
  elsif Rails.env.development?
    config.enable_processing = true
    config.storage           = :file
    config.asset_host        = ActionController::Base.asset_host
  else
    config.root              = Rails.root.join('tmp')
    config.cache_dir         = "#{Rails.root}/tmp/uploads"
    config.enable_processing = true
    config.storage           = :aws
    config.asset_host        = "https://#{ENV['AWS_BUCKET']}.s3.amazonaws.com"
    config.aws_acl           = 'public-read'
    config.aws_bucket        = ENV['AWS_BUCKET']
    config.aws_credentials   = {
      access_key_id:     ENV['AWS_ACCESS_ID'],
      secret_access_key: ENV['AWS_ACCESS_SECRET'],
      region:            ENV['AWS_REGION']
    }
    config.aws_attributes    = {
       expires: 1.week.from_now.httpdate,
       cache_control: 'max-age=604800'
    }
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
