require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  should belong_to(:user)
end