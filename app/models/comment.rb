class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :protip
  has_many :likes, as: :likable, dependent: :destroy

  validates :body, length: { minimum: 2 }
end
