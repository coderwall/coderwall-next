class StreamsController < ApplicationController

  def show
    @stream = Rails.cache.fetch("quickstream/stream/show", expires_in: 5.seconds) do
      Stream.live.sample
    end
    @user   = @stream.user
  end

  def index
    @streams = Rails.cache.fetch("quickstream/streams", expires_in: 5.seconds) do
      Stream.live
    end
  end
end
