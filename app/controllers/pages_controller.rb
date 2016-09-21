class PagesController < ApplicationController
  def show
    sanitized_params = params.permit(:page, :layout)
    respond_to do |format|
      format.html { render(action: sanitized_params[:page]) }
      format.all  { head(:not_found) }
    end
  end

  def verify
    render text: ENV['LETSENCRYPT_CODE']
  end

  def apple
    render file: "pages/apple-developer-merchantid-domain-association", layout: false
  end
end
