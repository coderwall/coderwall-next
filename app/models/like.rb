class Like < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :likable, polymorphic: true, counter_cache: true, touch: true, required: true

  def dom_id
    #Mimics ActionView::RecordIdentifier.dom_id without killing the database
    "#{temporarily_hacked_likable_type}_#{likable_id}".downcase
  end

  def temporarily_hacked_likable_type
    # the dom_id for these is protip, but in the database they're stored as Articles
    # this hack prevents hearting streams but that's ok for now
    likable_type == 'Article' ? 'Protip' : likable_type
  end
end
