require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many(:likes)
  should have_many(:pictures)
  should have_many(:protips)
  should have_many(:comments)
  should have_many(:badges)

  should validate_presence_of(:username)
  should validate_presence_of(:email)
end