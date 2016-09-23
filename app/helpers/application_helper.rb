module ApplicationHelper

  def show_ads?
    ENV['SHOW_ADS'] == 'true' || Rails.env.development?
  end

  def  darkened_bg_image(filename)
    transparency = '0.60'
    "background-image: linear-gradient(to bottom, rgba(0,0,0,#{transparency}) 0%,rgba(0,0,0,#{transparency}) 100%), url(#{asset_path(filename)});"
  end

  def time_ago_in_words_with_ceiling(time)
    if time < 1.year.ago
      'over 1 year'
    else
      time_ago_in_words(time)
    end
  end

  def hide_on_profile
    return 'hide' if params[:controller] == 'users'
  end

  def hide_on_chat
    return 'hide' if params[:controller] == 'streams'
  end

  def hide_border_on_chat
    return 'no-border-ever' if params[:controller] == 'streams'
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
      charset: 'UTF-8',
      viewport: 'width=device-width,initial-scale=1',
      description: "Programming tips, tools, and projects from our developer community.",
      keywords: 'prgramming tips, coderwall, learn to program, code, coding, open source programming, OSS, developers, programmers',
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

  def next_lunch_and_learn
    day = Stream.next_weekly_lunch_and_learn
    day.strftime("%A %B #{day.day.ordinalize}")
  end

  def livestream_tweet_message
    attribution = @stream.user.twitter ? @stream.user.twitter : "coderwall"
    CGI.escape "[LIVE] #{@stream.title} via @#{attribution}\n\n#{profile_stream_url(username: @stream.user.username)}"
  end
end
