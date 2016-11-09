class SubscribersController < ApplicationController
  # TODO: shouldn't need this, not sure why X-CSRF-Token header isn't working
  skip_before_action :verify_authenticity_token

  before_action :require_login, only: [:create, :destroy, :mute]

  def create
    @protip = Protip.find(params[:protip_id])
    @protip.subscribe!(current_user)
    render json: @protip, root: false
  end

  def destroy
    @protip = Protip.find(params[:protip_id])
    @protip.unsubscribe!(current_user)
    render json: @protip, root: false
  end

  def mute
    @protip = Protip.find_by_public_id!(params[:protip_id])
    if params[:signature] != current_user.unsubscribe_signature
      flash[:notice] = "Unsubscribe link is no longer valid"
    else
      @protip.unsubscribe!(current_user)
      flash[:notice] = "You will no longer receive new comment emails"
    end
    redirect_to seo_protip_path(@protip)
  end
end
