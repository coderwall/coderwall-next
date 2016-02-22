module UsersHelper

  def current_user_liked_list
    if signed_in?
      current_user.liked
    else
      empty_json_array_so_font_end_continues = '[]'
    end
  end

  def finishing_signup?
    params[:finish_signup] == true
  end

  def show_badges?
    !show_protips? && !show_comments?
  end

  def show_protips?
    params[:protips].present?
  end

  def show_comments?
    params[:comments].present?
  end

  def show_badges_active
    return 'active' if show_badges?
  end

  def show_protips_active
    return 'active' if show_protips?
  end

  def show_comments_active
    return 'active' if show_comments?
  end

  def avatar_url(user)
    image_url user.avatar.url
  end

  def avatar_url_tag(user)
    image_tag(avatar_url(user)) if user.avatar.present?
  end

end
