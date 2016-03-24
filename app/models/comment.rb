class Comment < ApplicationRecord
  include TimeAgoInWordsCacheBuster
  paginates_per 10
  html_schema_type :Comment

  after_create :auto_like_protip_for_author

  belongs_to :user,   touch: true, required: true
  belongs_to :protip, touch: true, required: true
  has_many :likes, as: :likable, dependent: :destroy

  validates :body,   length: { minimum: 2 }

  scope :recently_created, ->(count=10) { order(created_at: :desc).limit(count)}

  def dom_id
    ActionView::RecordIdentifier.dom_id(self)
  end

  def auto_like_protip_for_author
    protip.likes.create(user: user) unless user.likes?(protip)
  end
end
