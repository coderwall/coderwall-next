class CoderwallFlavoredMarkdown < Redcarpet::Render::HTML
  USERNAME_BLACKLIST = %w(include)

  def self.render_to_html(text)
    return nil if text.nil?

    renderer  = CoderwallFlavoredMarkdown.new({
      escape_html:     true,
      safe_links_only: true,
      prettify:        true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow' }
    })

    extensions = {
      fenced_code_blocks:   true,
      autolink:             true,
      strikethrough:        true
    }

    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    html      = redcarpet.render(text)
    html
  end

  def postprocess(text)
    wrap_usernames_with_profile_link(text)    
  end

  def wrap_usernames_with_profile_link(text)
    text.lines.map do |line|
      if dont_link_mention_if_codeblock = line.start_with?('    ')
        line
      else
        line.gsub(/((?<!\s{4}).*)@([a-zA-Z_\-0-9]+)/) { $1+coderwall_link_for($2) }
      end
    end.join('')
  end

  def coderwall_link_for(username)
    (User.where(username: username).exists? && !USERNAME_BLACKLIST.include?(username)) ? ActionController::Base.helpers.link_to("@#{username}", "/#{username}") : "@#{username}"
  end

  def auto_embed_slideshare_links(text)
    # http://localhost:5000/p/lbtpuw/front-end-frameworks-a-quick-overview
    text
  end

  # def preprocess(text)
  #   turn_gist_links_into_embeds!(text)
  # end
  #
  # def postprocess(text)
  #   embed_gists!(text)
  # end
  #
  # def turn_gist_links_into_embeds!(text)
  #   text.gsub! /https?:\/\/gist\.github\.com\/(.*?)(\.js)?/ do
  #     "[gist #{Regexp.last_match.to_s}]"
  #   end
  #   raise text
  # end
  #
  # def embed_gists!(text)
  #   raise text
  #   text.gsub! /\[gist ([\w|\/]*)\]/ do
  #     "<script src='https://gist.github.com/#{$1}.js'></script>"
  #   end
  # end

end
