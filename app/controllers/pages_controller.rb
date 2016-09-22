class PagesController < ApplicationController
  def show
    sanitized_params = params.permit(:page, :layout)
    respond_to do |format|
      format.html { render(action: sanitized_params[:page]) }
      format.all  { head(:not_found) }
    end
  end  
end
