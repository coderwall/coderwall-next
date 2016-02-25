class AutoLikeContent < ActiveRecord::Migration
  def up
    Protip.find_each do |protip|
      protip.likes.create(user: protip.user) unless protip.user.likes?(protip)
    end
    Comment.find_each do |comment|
      comment.protip.likes.create(user: comment.user) unless comment.user.likes?(comment.protip)      
    end
  end

  def down
  end
end
