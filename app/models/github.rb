class Github
  class << self
    def user_comment_log
      fetch('/issues/comments').collect do |comment|
        {
          username:   comment['user']['login'],
          user_id:    comment['user']['id'],
          created_at: Time.parse(comment['created_at'])
        }
      end
    end

    def user_pr_log
      fetch('/pulls', state: 'all').collect do |pr|
        {
          username:   pr['user']['login'],
          user_id:    pr['user']['id'],
          created_at: Time.parse(pr['created_at'])
        }
      end
    end

    def user_issue_log
      fetch('/issues', state: 'all').collect do |pr|
        {
          username:   pr['user']['login'],
          user_id:    pr['user']['id'],
          created_at: Time.parse(pr['created_at'])
        }
      end
    end

    def fetch(path, options = {}, page = 1)
      repo       = 'coderwall-next'
      owner      = 'coderwall'
      connection = Faraday.new(url: "https://api.github.com")
      results    = []
      while true
        puts "[GitHub] Fetch #{path}: #{page}"
        response   = connection.get("/repos/#{owner}/#{repo}/#{path}", options.merge({page: page}))
        results    << JSON.parse(response.body)
        break if (response.headers['link'].to_s =~ /next/) == nil
        page = page + 1
      end
      results.flatten
    end
  end
end
