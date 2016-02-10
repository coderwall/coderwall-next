class UsersController < ApplicationController

  def show
    if params[:username] == 'random'
      @user = User.order("random()").first
    else
      @user = User.find_by_username(params[:username])
    end
  end

end
