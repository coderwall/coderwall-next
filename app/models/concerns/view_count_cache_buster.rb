module ViewCountCacheBuster
  extend ActiveSupport::Concern

  def cache_key
    "#{super}/v-#{view_count_key}"
  end

  def view_count_key
    if views_count < 150
      bust_cache_every_three_views  = views_count / 3
    else
      bust_cache_every_twenty_views = views_count / 20
    end
  end

end
