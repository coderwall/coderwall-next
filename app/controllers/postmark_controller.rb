class PostmarkController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    puts params.inspect
    render nothing: true, status: :ok
  end
end
