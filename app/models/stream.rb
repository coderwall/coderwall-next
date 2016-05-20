class Stream
  include ActiveModel::Model
  attr_accessor :user, :sources

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
    return User.limit(rand(9)).order('RANDOM()').map do |u|
      Stream.new(
        user: u,
        sources: {'rmtp' => "rtmp://live.coderwall.com/coderwall/whatupdave"}
      )
    end

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

  def tags
    Protip.where("id < ?", rand(Protip.count)).order("RANDOM()").first.tags
  end

  def viewer_count
    rand(1000)
  end

  def preview_image_url
    return 'http://placehold.it/400x800'
    "https://api.quickstream.io/coderwall/streams/#{user.username}.png?size=400x"
  end

  def live?
    @live ||= [true, false].sample
  end

  def comments
    return []
    Comment.limit(rand(100))
  end

  def title
    [
      'Streaming my favorite editor',
      'c++ commercial dev|enderkend station',
      '1dv600 - l03 – planning and managing projects',
      'mobile web design'
    ].sample
  end

  def about
    d = [nil, 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?'].sample
    d.blank? ? 'Nothing here. Say hi in chat.' : d
  end

  def rtmp_json
    sources['rtmp'].to_json
  end

end
