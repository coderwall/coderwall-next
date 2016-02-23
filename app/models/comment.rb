class Comment < ActiveRecord::Base
  html_schema_type :Comment

  belongs_to :user,   touch: true
  belongs_to :protip, touch: true
  has_many :likes, as: :likable, dependent: :destroy

  validates :protip, presence: true
  validates :user,   presence: true
  validates :body,   length: { minimum: 2 }

  scope :recently_created, ->(count=10) { order(created_at: :desc).limit(count)}

  def dom_id
    ActionView::RecordIdentifier.dom_id(self)
  end
end
