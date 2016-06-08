if current_user
  json.authorUrl user_path(current_user)
  json.authorUsername current_user.username
end
json.pusherKey ENV['PUSHER_KEY']
json.chatChannel @stream.dom_id

json.stream do
  json.extract! @stream, :id, :active
end

json.comments @comments, partial: 'comments/comment', as: :comment
