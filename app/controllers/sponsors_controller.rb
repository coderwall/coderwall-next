class SponsorsController < ApplicationController
  def show
    @sponsors = Sponsor.ads_for(remote_ip)
    render json: @sponsors
  end
end
