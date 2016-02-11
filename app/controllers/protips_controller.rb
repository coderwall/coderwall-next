class ProtipsController < ApplicationController

  def index
    order_by = params[:order_by] || 'created_at'
    @protips = Protip.includes(:user).order({order_by => :desc}).page params[:page]
  end

  def show
    return (@protip = Protip.random.first) if params[:id] == 'random'
    @protip = Protip.find_by_public_id!(params[:id])

    if params[:slug] != @protip.slug
      seo_url = slug_protips_url(id: @protip.public_id, slug: @protip.slug)
      return redirect_to(seo_url, status: 301)
    end

  end

end
