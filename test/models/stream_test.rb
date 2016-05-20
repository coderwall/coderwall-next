require File.expand_path("../../test_helper", __FILE__)

class StreamTest < ActiveSupport::TestCase
  should belong_to(:user)
  should have_many(:comments)

  def test_save_and_load
    Stream.create!(title: 'Watch me dive!', body: 'Some stuff', tags: ['swimming'])
  end
end
