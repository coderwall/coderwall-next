class Protip < ActiveRecord::Base

  def to_param
    self.public_id
  end
  
end
