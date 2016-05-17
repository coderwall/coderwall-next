class StreamsController < ApplicationController
  def index
    @streams = Rails.cache.fetch("quickstream/streams", expires_in: 5.seconds) do
      Stream.live
    end
  end
end
