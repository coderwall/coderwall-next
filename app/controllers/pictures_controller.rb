class PicturesController < ApplicationController
  before_action :require_login

  def create
    picture = current_user.pictures.create!(file: params[:file])
    render json: picture
  end
end
