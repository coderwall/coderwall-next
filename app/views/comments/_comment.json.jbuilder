json.extract! comment, :id, :created_at
json.authorUrl user_path(comment.user)
json.authorUsername comment.user.username
json.markup sanitize(CoderwallFlavoredMarkdown.render_to_html(comment.body))
