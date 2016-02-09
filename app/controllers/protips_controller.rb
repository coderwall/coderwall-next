class ProtipsController < ApplicationController
  # before_action :require_login, only: :index

  def index
    order_by = params[:order_by] || 'created_at'
    @protips = Protip.includes(:user).order({order_by => :desc}).page params[:page]
  end

  def show
    @protip = Protip.find_by_public_id!(params[:id])
  end

end
