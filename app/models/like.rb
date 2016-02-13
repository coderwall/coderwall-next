class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :likable, polymorphic: true, counter_cache: true

  validates :likable, presence: true
  validates :value, presence: true, numericality: { min: 1 }
end
