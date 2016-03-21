class HooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def sendgrid
    params[:_json].each do |data|
      puts data
      process_unsubscribe(data) if data['event'] == 'unsubscribe'
    end

    head(200)
  end

  # private

  def process_unsubscribe(data)
    User.where(email: data['email']).update_all(marketing_list: nil)
  end
end
