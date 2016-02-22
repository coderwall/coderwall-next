class ProtipSerializer < ActiveModel::Serializer
  include ActionView::Helpers

  attributes :public_id,
             :title,
             :body,
             :html,
             :tags,
             :hearts,
             :upvotes,
             :created_at,
             :user

  protected
  def title
    sanitize(object.title)
  end

  def body
    sanitize(object.body)
  end

  def html
    CFM::Markdown.render(object.body)
  end

  def hearts
    object.hearts_count
  end

  def upvotes
    object.hearts_count
  end

end
