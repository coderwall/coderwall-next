json.extract! comment, :id
json.created_at comment.video_timestamp
json.authorUrl user_path(comment.user)
json.authorUsername comment.user.username
json.markup sanitize(CoderwallFlavoredMarkdown.render_to_html(comment.body))
