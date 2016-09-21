require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "profile" do
    user = create(:user)

    get :show, username: user.username
    assert_response :success
  end
end
