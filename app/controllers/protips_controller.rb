class ProtipsController < ApplicationController
  before_action :require_login, only: [:new, :create, :edit, :update]

  def index
    order_by = (params[:order_by] ||= 'score')
    @protips = Protip.includes(:user).order({order_by => :desc}).page params[:page]
  end

  def show
    return (@protip = Protip.random.first) if params[:id] == 'random'
    @protip = Protip.find_by_public_id!(params[:id])

    if params[:slug] != @protip.slug
      seo_url = slug_protips_url(id: @protip.public_id, slug: @protip.slug)
      return redirect_to(seo_url, status: 301)
    end

    update_view_count(@protip)
  end

  def new

  end

  protected
  def update_view_count(protip)
    if !browser.bot? && browser.known?
      recently_viewed = cookies[:viewd_protips].to_s.split(':')
      if !recently_viewed.include?(protip.public_id)
        protip.increment!(:views_count)
        recently_viewed << protip.public_id
      end
      cookies[:viewd_protips] = {
        value:    recently_viewed.join(':'),
        expires:  10.minutes.from_now
      }
    end
  end

end
