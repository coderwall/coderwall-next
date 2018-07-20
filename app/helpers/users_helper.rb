module UsersHelper

  def finishing_signup?
    params[:finish_signup] == true
  end

  def current_user_can_edit?(object)
    signed_in? && current_user.can_edit?(object)
  end

  def show_protips?
    !show_comments?
  end

  def show_comments?
    params[:comments].present?
  end

  def show_protips_active
    return 'active ' if show_protips?
  end

  def show_comments_active
    return 'active ' if show_comments?
  end

  def avatar_url(user)
    image_url user.avatar.url
  end

  def avatar_url_tag(user, options = {})
    image_tag(avatar_url(user), options) if user.avatar?
  end

end
