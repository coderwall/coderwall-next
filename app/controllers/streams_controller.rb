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

  # def invite
  #   @calendar     = Icalendar::Calendar.new
  #   event         = Icalendar::Event.new
  #   event.start   = Date.civil().strftime("%Y%m%dT%H%M%S")
  #   event.end     = Date.civil().strftime("%Y%m%dT%H%M%S")
  #   event.summary = ''
  #   event.description = ''
  #   event.location    = ''
  #   @calendar.add event
  #   @calendar.publish
  #   # meetings.each do |meeting|
  #   #     # 4
  #   #     calendar.add_event(meeting.to_ics)
  #   #   end
  #   headers['Content-Type'] = "text/calendar; charset=UTF-8"
  #
  #   respond_to do |format|
  #     format.ics { render :text => @calendar.to_ical, layout: nil }
  #   end
  # end
end
