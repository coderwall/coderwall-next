class Protip < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy

  def to_param
    self.public_id
  end

end
