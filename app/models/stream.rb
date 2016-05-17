class Stream < Struct.new(:user, :sources)
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
      Stream.new(u, streamers[u.username]['sources'])
    end
  end
end
