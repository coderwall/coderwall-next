class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :hearts,
             :heartableId

  protected
  def hearts
    object.hearts_count
  end

  def heartableId
    object.dom_id
  end
end
