class Slack
  API   = 'https://slack.com/api/'
  COUNT = 1000

  class << self
    def notify!(emoji, message)
      return unless ENV['SLACK_WEBHOOK_URL']
      connection = Faraday.new(url: ENV['SLACK_WEBHOOK_URL'])
      response   = connection.post('', payload: {
        "icon_emoji" => emoji,
        'text'       => "#{message} (cc <!here>)"
      }.to_json)
    end

    def access_logs(page=1)
      connection = Faraday.new(url: API)
      logins    = []
      while true
        puts "[Slack] Fetch access logs: #{page}"
        response   = connection.post('team.accessLogs',
          token: ENV['SLACK_API_TOKEN'],
          count: COUNT,
          page:  page)
        data       = JSON.parse(response.body)
        logins     << data['logins']
        break if page >= data['paging']['pages']
        page += 1
      end
      logins.flatten
    end

    def channel_history(channel = 'general', oldest = 0)
      messages   = []
      channel_id = channel_id_for_name(channel)
      puts "[Slack] Fetch history for #{channel_id} (#{channel})"
      connection = Faraday.new(url: API)
      while true
        puts "[Slack] Fetch channel history since: #{oldest}"
        response   = connection.post('channels.history',
            token: ENV['SLACK_API_TOKEN'],
          channel: channel_id,
            count: 1000,
        inclusive: 1,
           oldest: oldest)
        data       = JSON.parse(response.body)
        messages   << data['messages']
        break if data['has_more'] == false
        oldest = data['messages'].last['ts']
      end
      messages.flatten
    end

    def username_for_user_id(id)
      throw "id is null" if id.nil?
      @usernames     ||= {}
      @usernames[id] ||= begin
        puts "[Slack] Fetch username for #{id}"
        connection = Faraday.new(url: API)
        response   = connection.post('users.info',
          token: ENV['SLACK_API_TOKEN'],
          user: id
        )
        data       = JSON.parse(response.body)
        data['user']['name']
      end
    end

    def channel_id_for_name(name)
      puts "[Slack] Fetch channels"
      connection = Faraday.new(url: API)
      response   = connection.post('channels.list', token: ENV['SLACK_API_TOKEN'])
      data       = JSON.parse(response.body)
      data['channels'].each do |channel|
        return channel['id'] if channel['name'] == name
      end
    end

    def user_access_log
      access_logs.inject([]) do |results, record|
        results << {
          username:   record['username'],
          user_id:    record['user_id'],
          created_at: Time.at(record['date_first'])
        }
        results << {
          username:   record['username'],
          user_id:    record['user_id'],
          created_at: Time.at(record['date_last'])
        }
        results
      end
    end

    def user_message_log
      channel_history.inject([]) do |results, record|
        if record['type'] == 'message' && record['subtype'].blank?
          results << {
            username:   username_for_user_id(record['user']),
            user_id:    record['user'],
            created_at: Time.at(record['ts'].split('.').first.to_i)
          }
        end
        results
      end
    end
  end
end
