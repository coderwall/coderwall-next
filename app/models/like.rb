class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :likable, polymorphic: true, counter_cache: true, touch: true

  validates :user,    presence: true
  validates :likable, presence: true
  validates_uniqueness_of :user, scope: [:likable_type, :likable_id]
end
