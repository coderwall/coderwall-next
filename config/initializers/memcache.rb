if ENV["MEMCACHEDCLOUD_SERVERS"]
  Rails.application.config.cache_store = :dalli_store, ENV["MEMCACHEDCLOUD_SERVERS"].split(','), {
    username:  ENV["MEMCACHEDCLOUD_USERNAME"],
    password:  ENV["MEMCACHEDCLOUD_PASSWORD"],
    pool_size: Integer(ENV["MEMCACHEDCLOUD_POOL"] || 5)
  }
end
