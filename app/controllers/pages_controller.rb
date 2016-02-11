class PagesController < ApplicationController
  def show
    sanitized_params = params.permit(:page, :layout)
    render action: sanitized_params[:page]
  end
end
