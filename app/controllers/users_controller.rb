class UsersController < ApplicationController

  def show
    # @user = User.order("random()").first 
    @user = User.find_by_username(params[:username])
  end

end
