class CommentMailer < BaseMailer
  def new_comment(user_id, comment_id)
    @to = User.unscoped.find(user_id)
    return prevent_delivery if !should_email?(@to)

    @comment = Comment.find(comment_id)
    @author = @comment.user
    @article = @comment.article

    @target = target_name(@article)

    thread_parts = [@article.id]
    message_parts = [@comment.id]
    options = list_headers(NewsFeedItem.to_s, @article.id, @to.username, thread_parts, message_parts, url_for(@comment.url_params)).merge(
      from: "#{@author.display_name} <notifications@coderwall.com>",
      to:   @to.email,
      subject: "Re: #{@article.title}"
    )

    mail(options) do |format|
      format.html { render layout: nil }
    end
  end

  protected

  def should_email?(user)
    user.banned_at? ||
      user.email_invalid_at? ||
      user.unsubscribed_comment_emails_at?
  end
end
