class CoderwallFlavoredMarkdown < Redcarpet::Render::HTML

  def self.render_to_html(text)
    return nil if text.blank?

    extensions = {
      fenced_code_blocks: true,
      strikethrough: true,
      autolink: true
    }

    renderer  = CoderwallFlavoredMarkdown.new(link_attributes: {rel: "nofollow"})
    redcarpet = Redcarpet::Markdown.new(renderer, extensions)
    redcarpet.render(text)
  end

  # def preprocess(text)
  #   turn_gist_links_into_embeds!(text)
  # end
  #
  # USERNAME_BLACKLIST = %w(include)
  # def coderwall_user_link(username)
  #   (User.where(username: username).exists? && !USERNAME_BLACKLIST.include?(username)) ? ActionController::Base.helpers.link_to("@#{username}", "/#{username}") : "@#{username}"
  # end
  #
  # def inspect_line(line)
  #   #hotlink coderwall usernames to their profile, but don't search for @mentions in code blocks
  #   if line.start_with?('    ')
  #     line
  #   else
  #     line.gsub(/((?<!\s{4}).*)@([a-zA-Z_\-0-9]+)/) { $1+coderwall_user_link($2) }
  #   end
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
