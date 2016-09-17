class Article < ActiveRecord::Base
  self.table_name = "protips"

  include ViewCountCacheBuster
  include TimeAgoInWordsCacheBuster
  extend FriendlyId

  friendly_id :slug_format, :use => :slugged
  paginates_per 40
  html_schema_type :TechArticle

  BIG_BANG = Time.parse("05/07/2012").to_i #date protips were launched
  before_update :cache_calculated_score!
  before_create :generate_public_id, if: :public_id_blank?
  after_create  :auto_like_by_author

  belongs_to :user,   autosave: true, touch: true
  has_many :comments, ->{ order(created_at: :asc) }, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5, maximum:  255 }
  validates :body, presence: true
  validates :tags, presence: true
  validates :slug, presence: true

  scope :with_any_tagged, ->(tags){ where("tags && ARRAY[?]::varchar[]", tags) }
  scope :with_all_tagged, ->(tags){ where("tags @> ARRAY[?]::varchar[]", tags) }
  scope :without_any_tagged, ->(tags){ where.not("tags && ARRAY[?]::varchar[]", tags) }
  scope :without_all_tagged, ->(tags){ where.not("tags @> ARRAY[?]::varchar[]", tags) }
  scope :random, ->(count=1) { order("RANDOM()").limit(count) }
  scope :recently_created, ->(count=5) { order(created_at: :desc).limit(count)}
  scope :recently_most_viewed, ->(count=5) { order(views_count: :desc).limit(count)}
  scope :all_time_popular, -> {where(public_id: %w{ewk0mq kvzbpa vsdrug os6woq w7npmq _kakfa})}

  def to_param
    self.public_id
  end

  def self.spam
    spammy = "
      title ILIKE '% OST %' OR
      title ILIKE '% PST %' OR
      title ILIKE '%exchange mailbox%' OR
      title ILIKE '% loans %' OR
      title ILIKE '%Exchange Migration%'
    "
    where(spammy)
  end

  def display_date
    "Last Updated: #{updated_at.to_formatted_s(:seo)}"
  end

  def hearts_count
    likes_count
  end

  def related_topics
    tags.collect{|tag| Category.parent(tag) || Category.is_parent?(tag) }.compact.uniq
  end

  def slug_format
    title.to_s
  end

  def images
    image_matching_regex = /(https?:\/\/[\w.-\/]*?\.(jpe?g|gif|png))/
    body.to_s.scan(image_matching_regex)
  end

  def cacluate_content_quality_score
    decent_article_size = 300
    max_boost = 3.0
    factor = 1
    factor += [(body.length/decent_article_size), max_boost].min
    factor += [images.size, max_boost].min
    factor * (weight = 20)
  end

  def cacluate_score
    return 0 if flagged?
    half_life      = 2.days.to_i
    # gravity        = 1.8 #used to look at upvote_velocity(1.week.ago)
    views_score    = views_count / 100.0
    votes_score    = likes_count
    comments_score = comments.size #used to consider comment likes as upvotes (.reduce(:+))
    quality_score  = cacluate_content_quality_score
    author_score   = [-14 + user.account_age_in_days, 1].min

    points = [votes_score + views_score + comments_score + quality_score + author_score, 0].max
    total  = (created_at || Time.now).to_i.to_f / half_life + Math.log2(points + 1)

    Rails.logger.info "#{public_id} => #{score} (v:#{views_score} u:#{votes_score} q:#{quality_score} a:#{author_score})"

    total
  end

  def dom_id
    ActionView::RecordIdentifier.dom_id(self)
  end

  def generate_public_id
    self.public_id = SecureRandom.urlsafe_base64(4).downcase
    #retry if not unique
    generate_public_id unless Protip.where(public_id: self.public_id).blank?
  end

  def public_id_blank?
    public_id.blank?
  end

  def cache_calculated_score!
    self.score = cacluate_score
  end

  def display_tags
    tags.first(4).join(' ')
  end

  def editable_tags
    tags.join(', ')
  end

  def increment_view_count!
    self.views_count = views_count + 1
    dont_trigger_updated_at = update_column(:views_count, views_count)
  end

  def editable_tags=(val)
    self.tags = val.to_s.downcase.split(',').collect(&:strip).uniq
  end

  def auto_like_by_author
    likes.create(user: user)
  end

  def subscribe!(user)
    Protip.where(id: id).update_all(
      "subscribers = array(select unnest(subscribers) union select #{ActiveRecord::Base.connection.quote(user.id)})"
    )
    reload
  end

  def unsubscribe!(user)
    Protip.where(id: id).update_all(
      "subscribers = array(select i from unnest(subscribers) t(i) where i <> #{ActiveRecord::Base.connection.quote(user.id)})"
    )
    reload
  end
end
