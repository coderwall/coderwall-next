# https://github.com/schneems/puma_worker_killer
PumaWorkerKiller.config do |config|
  config.ram           = Integer(ENV['MAX_RAM'] || 512) # mb
  config.frequency     = 20   # seconds
  config.percent_usage = 0.95
  config.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds
end
PumaWorkerKiller.start
