module UsersHelper

  def current_user_liked_list
    # what it was on protip
    #signed-in-user-liked-payload.hide=current_user.likes?(@protip) && [dom_id(@protip)]
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
    !params[:protips].present?
  end

  def show_badges_active
    return 'active' if show_badges?
  end

  def show_protips_active
    return 'active' unless show_badges?
  end

  def avatar_url(user)
    image_url user.avatar.url
  end
end
