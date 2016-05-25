if current_user
  json.authorUrl user_path(current_user)
  json.authorUsername current_user.username
end
json.signedIn !!current_user

json.stream do
  json.extract! @stream, :id
end

json.comments @comments, partial: 'comments/comment', as: :comment
