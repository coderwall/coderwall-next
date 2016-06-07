class StreamsController < ApplicationController
  include ActionController::Live

  before_action :require_login, only: [:new]

  def new
    @stream = current_user.active_stream || Stream.new(user: current_user)
    if @stream.new_record?
      if old_stream = current_user.streams.order(created_at: :desc).first
        @stream.title = old_stream.title
        @stream.body = old_stream.body
        @stream.tags = old_stream.tags
      end
    end
    if current_user.stream_key.blank?
      current_user.generate_stream_key
      current_user.save!
    end
  end

  def create
    @stream = current_user.streams.new(stream_params)
    save_and_redirect
  end

  def update
    @stream = current_user.active_stream
    @stream.assign_attributes(stream_params)
    save_and_redirect
  end

  def show
    @user = User.find_by!(username: params[:username])
    if @stream = @user.streams.order(created_at: :desc).first!
      @stream.broadcasting = !!cached_stats
    end
  end

  def index
    @streams = Rails.cache.fetch("quickstream/streams", expires_in: 5.seconds) do
      Stream.broadcasting
    end
  end

  def stats
    render json: cached_stats
  end

  def cached_stats
    Rails.cache.fetch("quickstream/#{params[:username]}/stats", expires_in: 5.seconds) do
      Stream.live_stats(params[:username])
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

  # private

  def stream_params
    params.require(:stream).permit(:title, :body, :editable_tags, :save_recording)
  end

  def save_and_redirect
    @stream.published_at ||= Time.now if params[:publish_stream]
    @stream.archived_at ||= Time.now if params[:end_stream]
    current_user.streams.where(archived_at: nil).update_all(archived_at: Time.now)
    if @stream.save
      case
      when @stream.archived?
        end_youtube_stream
        flash[:notice] = "Your stream has been archived"
        redirect_to live_streams_path
      when @stream.published?
        Rails.logger.info("pushing to youtube")
        stream_to_youtube if @stream.save_recording
        redirect_to profile_stream_path(current_user.username)
      else
        redirect_to new_stream_path
      end
    else
      render 'new'
    end
  end

  def stream_to_youtube
    url = "#{ENV['QUICKSTREAM_URL']}/streams/#{@stream.user.username}/youtube"
    Excon.put(url,
      headers: {
        "Accept" => "application/json",
        "Content-Type" => "application/json" },
      body: {title: @stream.title, description: @stream.body}.to_json,
      idempotent: true,
      tcp_nodelay: true,
    )
  end

  def end_youtube_stream
    url = "#{ENV['QUICKSTREAM_URL']}/streams/#{@stream.user.username}/youtube"
    Excon.delete(url,
      headers: {
        "Accept" => "application/json",
        "Content-Type" => "application/json" },
      idempotent: true,
      tcp_nodelay: true,
    )
  end
end
