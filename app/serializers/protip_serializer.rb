class ProtipSerializer < ActiveModel::Serializer
  include ActionView::Helpers

  attributes :id,
             :body,
             :created_at,
             :heartableId,
             :hearts,
             :html,
             :public_id,
             :subscribed,
             :tags,
             :title,
             :upvotes,
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

  def subscribed
    return false unless scope

    object.subscribers.include?(scope.id)
  end

  def heartableId
    object.dom_id
  end

  def hearts
    object.hearts_count
  end

  def upvotes
    object.hearts_count
  end
end
