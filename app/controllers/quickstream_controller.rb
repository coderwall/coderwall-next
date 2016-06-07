class QuickstreamController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    @user = User.find_by!(stream_key: params[:token])
    render nothing: true, status: :ok
  end
end
