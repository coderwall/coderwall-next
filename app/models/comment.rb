class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :protip
  has_many :likes, as: :likable, dependent: :destroy

  validates :protip, presence: true
  validates :user,   presence: true
  validates :body,   length: { minimum: 2 }

  scope :recently_created, ->(count=10) { order(created_at: :desc).limit(count)}

  def dom_id
    ActionView::RecordIdentifier.dom_id(self)
  end
end
