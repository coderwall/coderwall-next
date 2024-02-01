class Comment < ApplicationRecord
  include TimeAgoInWordsCacheBuster
  paginates_per 10

  VIDEO_LAG = 25.seconds # TODO: measure the real lag value

  after_create :auto_like_article_for_author

  belongs_to :user,   touch: true, required: true
  belongs_to :article, touch: true, required: true
  has_many :likes, as: :likable, dependent: :destroy

  validates :body,   length: { minimum: 2 }

  scope :on_protips, -> { joins(:article).where(protips: {type: 'Protip'}) }
  scope :visible_to, ->(user) { where(bad_content: false) unless user.try(:bad_user) }
  scope :recently_created, ->(count=10) { order(created_at: :desc).limit(count)}

  def auto_like_article_for_author
    article.likes.create(user: user) unless user.likes?(article)
  end

  def dom_id
    ActionView::RecordIdentifier.dom_id(self)
  end

  def hearts_count
    likes_count
  end

  def url_params
    [article, anchor: dom_id]
  end

  def video_timestamp
    (created_at - VIDEO_LAG).to_i
  end
end
