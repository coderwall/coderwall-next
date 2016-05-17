module ApplicationHelper

  def show_ads?
    ENV['SHOW_ADS'] == 'true' || Rails.env.development?
  end

  def time_ago_in_words_with_ceiling(time)
    if time < 1.year.ago
      'over 1 year'
    else
      time_ago_in_words(time)
    end
  end

  def hide_on_streams
    return 'hide' if params[:controller] == 'streams'
  end

  def hide_on_auth
    if params[:controller] == 'clearance/sessions'  ||
       params[:controller] == 'clearance/users'     ||
       params[:controller] == 'clearance/passwords' ||
       params[:page] == 'not_found'                 ||
       params[:page] == 'server_error'              ||
       params[:finish_signup].present?
      return 'hide'
    end
  end

  def default_meta_tags
    {
      site: 'Coderwall',
      charset: 'UTF-8',
      viewport: 'width=device-width,initial-scale=1',
      description: "Coderwall makes the software world smaller so you can meet, learn from, and work with other inspiring developers",
      keywords: 'coderwall, learn to program, code, coding, open source programming, OSS, developers, programmers',
      og: {
        title: :title,
        url: :canonical,
        site_name: 'Coderwall',
        description: :description,
        type: 'website'

      },
      twitter: {
        title: :title,
        url: :canonical,
        site_name: 'Coderwall',
        site: '@coderwall',
        card: 'summary'
      }
    }
  end

  def meta(meta_tags)
    set_meta_tags(meta_tags)
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
