class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :protip

  validates :body, length: { minimum: 2 }
end
