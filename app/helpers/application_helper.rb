module ApplicationHelper

  def hide_on_auth    
    if params[:controller] == 'clearance/sessions' ||
       params[:controller] == 'clearance/users'    ||
       params[:controller] == 'clearance/passwords'
      return 'hide'
    end
  end

end
