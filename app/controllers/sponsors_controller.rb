class SponsorsController < ApplicationController
  def show
    @sponsors = Sponsor.ads_for(request.remote_ip)
    render json: @sponsors
  end
end
