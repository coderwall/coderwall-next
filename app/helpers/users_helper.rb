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
    # return 'https://s3.amazonaws.com/uifaces/faces/twitter/felipenogs/24.jpg'
    # user.avatar.url
  end

  # .avatar{style: "background-color: #303544; width: 50px; height: 50px"}
  #   %span{style: "background-color: #{@user.color}; width: 45px; height: 45px; float: right"}
  #     %span{style: "background-color: #{@user.color}; width: 40px; height: 40px; float: right"}
  #       %span{style: "background-color: #{@user.color}; width: 35px; height: 35px; float: right"}
  #         %span{style: "background-color: #{@user.color}; width: 30px; height: 30px; float: right"}
  #           %span{style: "background-color: #{@user.color}; width: 25px; height: 25px; float: right"}
  #             %span{style: "background-color: #{@user.color}; width: 20px; height: 20px; float: right"}
  #               %span{style: "background-color: #{@user.color}; width: 15px; height: 15px; float: right"}
  #                 %span{style: "background-color: #{@user.color}; width: 10px; height: 10px; float: right"}


end
