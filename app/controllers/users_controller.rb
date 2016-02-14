class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update, :create]

  def show
    if params[:username] == 'random'
      @user = User.order("random()").first
    else
      @user = User.find_by_username(params[:username])
    end
  end

  def impersonate
    if Rails.env.development? || current_user.admin?
      user = User.find_by_username(params[:username])
      sign_in(user)
      redirect_to profile_url(username: user.username)
    end
  end

end
