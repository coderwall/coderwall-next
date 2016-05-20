class RenameProtipIdOnCommentsToArticleId < ActiveRecord::Migration
  def change
    rename_column :comments, :protip_id, :article_id
    Like.where(likable_type: 'Protip').update_all(likable_type: 'Article')
  end
end
