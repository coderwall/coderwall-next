require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup { ActionMailer::Base.deliveries = [] }

  test "creating comment sends email update to author" do
    protip = create(:protip, user: create(:user, email: 'author@example.com'))
    author = protip.user
    commentor = create(:user, email: 'commentor@example.com')
    sign_in_as commentor

    post :create, params: { comment: { body: 'Justice rains from above!', article_id: protip.id } }

    email = ActionMailer::Base.deliveries.last

    assert_match "Re: #{protip.title}", email.subject
    assert_equal author.email, email.to[0]
    assert_match(/Justice/, email.body.to_s)
  end

  test "creating comment won't send email if muted" do
    protip = create(:protip, user: create(:user, email: 'author@example.com'))
    author = protip.user
    protip.unsubscribe!(author)
    commentor = create(:user, email: 'commentor@example.com')
    sign_in_as commentor

    post :create, params: {
      comment: { body: 'Justice rains from above!', article_id: protip.id }
    }

    email = ActionMailer::Base.deliveries.last

    assert_nil email
  end

  test "comments can't be posted too fast" do
    protip = create(:protip)
    commentor = create(:user)
    sign_in_as commentor

    assert_difference 'Comment.count', 1 do
      post :create, params: { comment: { body: 'first!', article_id: protip.id } }
    end

    Timecop.freeze(1.second.from_now) do
      assert_difference 'Comment.count', 0 do
        post :create, params: { comment: { body: 'second!', article_id: protip.id } }
      end
    end

    Timecop.freeze(1.hour.from_now) do
      assert_difference 'Comment.count', 1 do
        post :create, params: { comment: { body: 'second!', article_id: protip.id } }
      end
    end
  end
end
