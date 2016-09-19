require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup { ActionMailer::Base.deliveries = [] }

  test "creating comment sends email update to author" do
    protip = create(:protip, user: create(:user, email: 'author@example.com'))
    protip.run_callbacks(:commit)
    author = protip.user
    commentor = create(:user, email: 'commentor@example.com')
    sign_in_as commentor

    post :create, comment: { body: 'Justice rains from above!', article_id: protip.id }

    email = ActionMailer::Base.deliveries.last

    assert_match "Re: #{protip.title}", email.subject
    assert_equal author.email, email.to[0]
    assert_match(/Justice/, email.body.to_s)
  end

  test "creating comment won't send email if muted" do
    protip = create(:protip, user: create(:user, email: 'author@example.com'))
    author = protip.user
    commentor = create(:user, email: 'commentor@example.com')
    sign_in_as commentor

    post :create, comment: { body: 'Justice rains from above!', article_id: protip.id }

    email = ActionMailer::Base.deliveries.last

    assert_nil email
  end
end
