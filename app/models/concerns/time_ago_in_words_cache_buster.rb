module TimeAgoInWordsCacheBuster
  extend ActiveSupport::Concern

  HOUR_IN_MINUTES  = 60
  DAY_IN_MINUTES   = HOUR_IN_MINUTES * 24
  WEEK_IN_MINUTES  = DAY_IN_MINUTES  * 7
  MONTH_IN_MINUTES = WEEK_IN_MINUTES * 4

  def cache_key
    "#{super}/t-#{time_interval_key}"
  end

  def time_interval_key
    minutes = ((Time.now - updated_at) / 60.0).round
    if minutes <= HOUR_IN_MINUTES
      (Time.now - updated_at) / 60.0
    elsif minutes <= DAY_IN_MINUTES
      (minutes / DAY_IN_MINUTES).round
    elsif minutes <= WEEK_IN_MINUTES
      (minutes / DAY_IN_MINUTES).round
    else
      (minutes / MONTH_IN_MINUTES).round
    end
  end
end
