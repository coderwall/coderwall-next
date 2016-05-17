class Stream
  include ActiveModel::Model
  attr_accessor :user, :sources

  # html_schema_type :BroadcastEvent

  def self.live
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

  def id
    object_id
  end

  def rtmp_json
    sources['rtmp'].to_json
  end

end
