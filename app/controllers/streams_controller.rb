class StreamsController < ApplicationController
  include ActionController::Live

  def show
    @user = User.find_by!(username: params[:username])
    @stream = Rails.cache.fetch("quickstream/#{@user.id}/show", expires_in: 5.seconds) do
      @user.streams.first
    end
  end

  def index
    @streams = Rails.cache.fetch("quickstream/streams", expires_in: 5.seconds) do
      Stream.live
    end
  end

  def invite
    @calendar = Icalendar::Calendar.new
    timezone  = 'America/Los_Angeles' #'America/New_York'
    starts    = Stream.next_weekly_lunch_and_learn
    ends      = (starts + 3.hours)
    from      = "mailto:support@coderwall.com"

    @calendar.event do |e|
      e.dtstart     = Icalendar::Values::DateTime.new(starts, tzid: timezone)
      e.dtend       = Icalendar::Values::DateTime.new(ends,   tzid: timezone)
      e.summary     = "Live Streamed Lunch & Learns"
      e.description = "Join the community once a week for a lunch and learn where developers and designers live stream their latest tips, tools, and projects. It's fun for n00bs to masters.\n\nNote: If you plan to participate and live stream yourself, please visit Coderwall and test live streaming before the event. Contact us if you have questions."
      e.url         = 'https://coderwall.com/live?ref=lunchandlearn'
      e.location    = 'Coderwall'
      e.organizer   = from
      e.organizer   = Icalendar::Values::CalAddress.new(from, cn: 'Coderwall Live')
      e.alarm do |a|
        a.action  = "DISPLAY"
        a.summary = "Alarm notification"
        a.trigger = "-P0DT1H30M0S"
      end
    end
    @calendar.publish
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    render :text => @calendar.to_ical, layout: nil
  end
end
