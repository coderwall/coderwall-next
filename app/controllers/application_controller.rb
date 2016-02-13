class ApplicationController < ActionController::Base
  include Clearance::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :record_user_access

  private
  def record_user_access
    if signed_in?
      current_user.update_columns(last_request_at: Time.now, last_ip:request.remote_ip)
    end
  end
end
