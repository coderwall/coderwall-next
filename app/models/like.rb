class Like < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :likable, polymorphic: true, counter_cache: true, touch: true, required: true

  def dom_id
    #Mimics ActionView::RecordIdentifier.dom_id without killing the database
    "#{likable_type}_#{likable_id}".downcase
  end
end
