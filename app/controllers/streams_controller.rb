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
    elsif @stream.active
      return redirect_to profile_stream_path(current_user.username)
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
    load_stream
  end

  def index
    @live_streams = Rails.cache.fetch("quickstream/streams", expires_in: 5.seconds) do
      Stream.broadcasting
    end
    @recorded_streams = Stream.archived.recorded
  end

  def popout
    load_stream
    render layout: 'minimal'
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

  def load_stream
    if params[:username]
      @user = User.find_by!(username: params[:username])
      if @stream = @user.active_stream
        @stream.broadcasting = !!cached_stats
      end
    else
      @stream = Stream.find_by!(public_id: (params[:stream_id] || params[:id]))
      @user = @stream.user
    end
  end

  def save_and_redirect
    @stream.published_at ||= Time.now if params[:publish_stream]
    @stream.archived_at ||= Time.now if params[:end_stream]
    current_user.streams.where(archived_at: nil).update_all(archived_at: Time.now)
    if @stream.save
      case
      when @stream.archived?
        @stream.touch(:archived_at)
        flash[:notice] = "You are offline and your broadcast was archived"
        redirect_to new_stream_path
        background do
          end_youtube_stream
        end
      when @stream.published?
        Rails.logger.info("pushing to youtube")
        @stream.notify_team!
        redirect_to profile_stream_path(current_user.username)
        background do
          stream_to_youtube
        end
      else
        redirect_to new_stream_path
      end
    else
      render 'new'
    end
  end

  def stream_to_youtube
    url = "#{ENV['QUICKSTREAM_URL']}/streams/#{@stream.user.username}/youtube"
    resp = Excon.put(url,
      headers: {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "X-YouTube-Token" => ENV['YOUTUBE_OAUTH_TOKEN']},
      body: {title: @stream.title, description: @stream.body}.to_json,
      idempotent: true,
      tcp_nodelay: true,
    )
    body = JSON.parse(resp.body)
    @stream.update!(recording_id: body['youtube_broadcast_id'])
  end

  def end_youtube_stream
    url = "#{ENV['QUICKSTREAM_URL']}/streams/#{@stream.user.username}/youtube"
    Excon.delete(url,
      headers: {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "X-YouTube-Token" => ENV['YOUTUBE_OAUTH_TOKEN']},
      idempotent: true,
      tcp_nodelay: true,
    )
  end
end
