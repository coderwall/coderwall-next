class QuickstreamController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    @user = User.find_by!(stream_key: params[:token])
    head(200)
  end

  # private

  def process_unsubscribe(data)
    User.where(email: data['email']).update_all(marketing_list: nil)
  end
end
