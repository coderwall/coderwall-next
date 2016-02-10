class Protip < ActiveRecord::Base
  paginates_per 30

  belongs_to :user, autosave: true
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy

  scope :random, ->(count=1) { order("RANDOM()").limit(count) }

  def to_param
    self.public_id
  end

  def display_date
    created_at.strftime('%B')
  end

  def heart_count
    rand(99)
  end

  def view_count
    rand(1000)
  end

  def tags
    ['ruby', 'rails', 'python', 'docker', 'osx', 'linux'].sample(rand(6))
  end

end
