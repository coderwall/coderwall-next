require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "unsubscribe from comment emails" do
    user = create(:user)
    sign_in_as user

    get :unsubscribe_comment_emails, signature: user.unsubscribe_signature
    assert_redirected_to root_path
    assert_not_nil user.reload.unsubscribed_comment_emails_at
  end
end
