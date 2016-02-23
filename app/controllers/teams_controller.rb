class TeamsController < ApplicationController

  def show
    if params[:slug] == 'random'
      @team = Team.order("random()").first
    else
      @team = Team.find_by_slug(params[:slug])
    end
  end

end
