require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  test "creating comment sends email update to author" do
    protip = create(:protip)
    author = protip.user
    commentor = create(:user)
    sign_in_as commentor

    post :create, comment: { body: 'Justice rains from above!', article_id: protip.id }

    email = ActionMailer::Base.deliveries.last

    assert_match "Re: #{protip.title}", email.subject
    assert_match author.email, email.to[0]
    assert_match(/Justice/, email.body.to_s)
  end
end
