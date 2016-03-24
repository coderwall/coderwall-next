class TeamsController < ApplicationController

  def show
    @team = Team.find_by_slug!(params[:slug])
  end

  def random
    @team = Team.order("random()").first
    render :show
  end

end
