class Notification
  class LoggingClient
    def trigger(channel, event, data, options = {})
      Rails.logger.info "[Pusher] #{channel} #{event} #{data.inspect}"
    end
  end

  class << self
    def pusher
      return LoggingClient.new if Rails.env.test?

      Pusher
    end

    def comment_added!(article, json, socket_id = nil)
      trigger(article, 'new-comment', json, socket_id)
    end

    protected

    def trigger(model, event, payload, socket_id)
      channel = to_chan(model)
      Rails.logger.info "[Pusher] #{channel} #{event} #{payload.inspect}"
      pusher.trigger(channel, event, payload, socket_id: socket_id)
    end

    def to_chan(model)
      # Pusher don't like global ids as channel names
      # this will convert it to something we can use
      model.to_global_id.to_s.split('/')[3..-1].join(',')
    end

    def self.to_model(chan)
      # and then convert it back to a global id
      gid = "gid://#{GlobalID.app}/#{chan.split(',').join('/')}"
      GlobalID.find(gid)
    end
  end
end
