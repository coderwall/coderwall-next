class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]

  def show
    if params[:username] == 'random'
      @user = User.order("random()").first
    else
      @user = User.find_by_username(params[:username])
    end
  end

  def edit
    @user = User.where(id: params[:id]).first || current_user
    return head(:forbidden) unless authorized?(@user)
  end

  def create
    return head(:forbidden) if signed_in?
    @user = User.new(new_user_params)
    if @user.save
      sign_in(@user)
      redirect_to finish_signup_url
    else
      render action: :new
    end
  end

  def index
    redirect_to sign_up_url
  end

  def update
    @user = User.find(params[:id])
    return head(:forbidden) unless authorized?(@user)
    @user.attributes = user_params
    if @user.save
      redirect_to profile_url(username: @user.username)
    else
      render action: :edit
    end
  end

  def impersonate
    if Rails.env.development? || current_user.admin?
      user = User.find_by_username(params[:username])
      sign_in(user)
      redirect_to profile_url(username: user.username)
    end
  end

  protected
  def authorized?(user)
    current_user == user || admin?
  end

  def new_user_params
    params.require(:user).permit(:username, :password, :email)
  end

  def user_params
    safe_attributes = [
      :twitter,
      :github,
      :email,
      :title,
      :company,
      :location,
      :about,
      :receive_newsletter,
      :receive_weekly_digest
    ]
    safe_attributes << :username if admin?
    params.require(:user).permit(safe_attributes)
  end

end
