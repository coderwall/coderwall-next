class QuickstreamController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    case params[:type].to_sym
    when :auth
      @user = User.find_by!(stream_key: params[:token])
    when :youtube_live
      puts params[:broadcast]
      broadcast_id = params[:broadcast]['id']
      @stream = Stream.joins(:user).find_by!('users.username' => params[:streamer], :recording_id => broadcast_id)
      @stream.update!(recording_started_at: Time.parse(params[:broadcast]['snippet']['actual_start_time']))
    end
    render nothing: true, status: :ok
  end
end
