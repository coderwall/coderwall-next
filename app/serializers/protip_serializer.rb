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
             :subscribers,
             :user

  protected
  def title
    sanitize(object.title)
  end

  def body
    sanitize(object.body)
  end

  def html
    CoderwallFlavoredMarkdown.render_to_html(object.body)
  end

  def hearts
    object.hearts_count
  end

  def upvotes
    object.hearts_count
  end

end
