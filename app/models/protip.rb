class Protip < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_format, :use => :slugged
  paginates_per 30

  belongs_to :user, autosave: true
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy

  scope :random, ->(count=1) { order("RANDOM()").limit(count) }
  scope :recently_created, ->(count=5) { order(created_at: :desc).limit(count)}
  scope :recently_most_viewed, ->{ order(views_count: :desc).where(public_id: %w{ewk0mq kvzbpa vsdrug os6woq w7npmq _kakfa}) }


  def to_param
    self.public_id
  end

  def display_date
    created_at.strftime('%B')
  end

  def hearts_count
    likes_count
  end

  def slug_format
    "#{title}"
  end

end
