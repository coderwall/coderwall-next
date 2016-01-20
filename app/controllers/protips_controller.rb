class ProtipsController < ApplicationController

  def index
    @protips = Protip.order("score DESC").limit(30)
  end

  def show
    @protip = Protip.find_by_public_id!(params[:id])
  end

end
