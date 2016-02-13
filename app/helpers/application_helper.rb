module ApplicationHelper

  def hide_on_auth
    if params[:controller] == 'clearance/sessions'  ||
       params[:controller] == 'clearance/users'     ||
       params[:controller] == 'clearance/passwords' ||
       params[:page] == 'not_found' ||
       params[:page] == 'server_error'
      return 'hide'
    end
  end

  def meta_person_schema_url
    'https://schema.org/Person'
  end

  def meta_address_schema_url
    'https://schema.org/Address'
  end

  def meta_article_schema_url
    'https://schema.org/TechArticle'
  end

  def meta_comment_schema_url
    'https://schema.org/Comment'
  end
  
end
