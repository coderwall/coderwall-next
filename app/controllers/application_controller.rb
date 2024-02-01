class ApplicationController < ActionController::Base
  # include ReactOnRails::Controller
  include Clearance::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :strip_and_redirect_on_www
  after_action :record_user_access

  protected
  def admin?
    signed_in? && current_user.admin?
  end
  helper_method :admin?

  def deny_access(flash_message = nil)
    respond_to do |format|
      format.json { render json: { type: :unauthorized }, status: 401 }
      format.any(:js) { head :unauthorized }
      format.any { redirect_request(flash_message) }
    end
  end

  def dom_id(klass, id)
    [ActionView::RecordIdentifier.dom_class(klass), id].join('_')
  end

  def record_user_access
    if signed_in?
      current_user.update_columns(last_request_at: Time.now, last_ip: remote_ip)
    end
  end

  def default_store_data
    {
      currentUser: { item: serialize(current_user) }
    }
  end

  def store_data(props=nil)
    @store_data ||= default_store_data
    return @store_data if props.nil?

    @store_data.merge!(props)
  end
  helper_method :store_data

  def strip_and_redirect_on_www
    if Rails.env.production?
      if request.env['HTTP_HOST'] != ENV['DOMAIN']
        redirect_to request.url.sub("//www.", "//"), status: 301
      end
    end
  end

  def redirect_to_back_or_default(default = root_url)
    if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      redirect_to :back
    else
      redirect_to default
    end
  end

  def background
    Thread.new do
      yield
      ActiveRecord::Base.connection.close
    end
  end

  def serialize(obj, serializer = nil)
    serializer ||= ActiveModel::Serializer.serializer_for(obj)
    serializer.new(obj, root: false, scope: current_user).as_json if obj
  end

  def remote_ip
    (request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip).split(",").first
  end

  def captcha_valid_user?(response, remoteip)
    return true if !ENV['CAPTCHA_SECRET']
    resp = Faraday.post(
      "https://www.google.com/recaptcha/api/siteverify",
      secret: ENV['CAPTCHA_SECRET'],
      response: response,
      remoteip: remoteip
    )
    logger.info resp.body
    JSON.parse(resp.body)['success']
  end

  def seo_protip_path(protip)
    slug_protips_path(id: protip.public_id, slug: protip.slug)
  end
  helper_method :seo_protip_path

end
