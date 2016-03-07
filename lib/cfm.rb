# encoding: utf-8
# require 'github/markup'
#coderwall flavored markdown
module CFM
  class Markdown
    class << self
      def render(text)
        return nil if text.nil?

        extensions = {
          fenced_code_blocks:   true,
          strikethrough:        true
        }

        options = {
          link_attributes: { rel: 'nofollow' }
        }

        renderer  = Redcarpet::Render::HTML.new(options)
        redcarpet = Redcarpet::Markdown.new(renderer, extensions)
        html      = redcarpet.render(render_cfm(text))
        html
      end

      # @html.gsub(/http:\/\/www\.youtube\.com\/watch\?v=(.*?)\s/, "....actual html $1")

      # https://gist.github.com/4265815
      # GitHub::Markup::Markdown.new.render(text)
      # %script{ src: "https://gist.github.com/4265815.js"}

      # def preprocess(text)
      #   wrap_mentions(text)
      # end
      #
      # def wrap_mentions(text)
      #   text.gsub! /(^|\s)(@\w+)/ do
      #     "#{$1}<span class='mention'>#{$2}</span>"
      #   end
      #   text
      # end

      USERNAME_BLACKLIST = %w(include)

      private
      def render_cfm(text)
        text.lines.map do |x|
          inspect_line(x)
        end.join('')
      end

      def coderwall_user_link(username)
        (User.where(username: username).exists? && !USERNAME_BLACKLIST.include?(username)) ? ActionController::Base.helpers.link_to("@#{username}", "/#{username}") : "@#{username}"
      end

      def inspect_line(line)
        #hotlink coderwall usernames to their profile, but don't search for @mentions in code blocks
        if line.start_with?('    ')
          line
        else
          line.gsub(/((?<!\s{4}).*)@([a-zA-Z_\-0-9]+)/) { $1+coderwall_user_link($2) }
        end
      end
    end
  end
end
