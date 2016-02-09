class Protip < ActiveRecord::Base
  paginates_per 30

  belongs_to :user, autosave: true
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy

  scope :random, ->(count=1) { order("RANDOM()").limit(count) }

  def to_param
    self.public_id
  end

end
