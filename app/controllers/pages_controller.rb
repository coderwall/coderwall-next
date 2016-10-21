class PagesController < ApplicationController
  def show
    args = params.permit(:page, :layout)
    status = 200
    status = 404 if args[:page].to_s == 'not_found'
    respond_to do |format|
      format.html { render(action: args[:page], status: status) }
      format.all  { head(:not_found) }
    end
  end
end
