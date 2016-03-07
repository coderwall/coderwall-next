require File.expand_path("../../test_helper", __FILE__)

class BadgeTest < ActiveSupport::TestCase
  should belong_to(:user)
end
