require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase
  test 'new comment' do
    user = create(:user)
    comment = create(:comment)
    article = comment.article

    email = CommentMailer.new_comment(user, comment)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["notifications@coderwall.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Re: #{article.title}", email.subject
  end
end
