class Stream < Article
  # include ActiveModel::Model
  # attr_accessor :user, :sources

  # html_schema_type :BroadcastEvent

  def self.next_weekly_lunch_and_learn
    friday = (Time.now.beginning_of_week + 4.days)
    event  = Time.new(friday.utc.year, friday.utc.month, friday.utc.day, 9, 30, 0)
    if already_passed = (Time.now > event)
      event + 1.week
    else
      event
    end
  end

  def self.any_live?
    true
  end

  def self.live
    # return User.limit(rand(9)).order('RANDOM()').map do |u|
    #   Stream.new(
    #     user: u,
    #     sources: {'rmtp' => "rtmp://live.coderwall.com/coderwall/whatupdave"}
    #   )
    # end

    resp = Excon.get("#{ENV['QUICKSTREAM_URL']}/streams",
      headers: {
        "Content-Type" => "application/json" },
      idempotent: true,
      tcp_nodelay: true,
    )

    streamers = JSON.parse(resp.body).each_with_object({}) do |s, memo|
      memo[s['streamer']] = s
    end

    User.where(username: streamers.keys).map do |u|
      Stream.new(user: u, sources: streamers[u.username]['sources'])
    end
  end

  def preview_image_url
    return 'http://placehold.it/400x800'
    "https://api.quickstream.io/coderwall/streams/#{user.username}.png?size=400x"
  end

  def live?
    @live ||= [true, false].sample
  end

  def rtmp_json
    sources['rtmp'].to_json
  end

end
