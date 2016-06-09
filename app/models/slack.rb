class Slack
  class << self
    def notify!(emoji, message)
      return unless ENV['SLACK_WEBHOOK_URL']
      connection = Faraday.new(url: ENV['SLACK_WEBHOOK_URL'])
      response   = connection.post('', payload: {
        "icon_emoji" => emoji,
        'text'       => "#{message} (cc <!here>)"
      }.to_json)
    end
  end
end
