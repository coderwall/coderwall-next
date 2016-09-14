class CommentMailer < BaseMailer
  def new_comment(to, comment)
    @to = to
    @comment = comment

    return prevent_delivery if prevent_email?(@to)

    if rewrite = ENV['REWRITE_EMAILS']
      @to.email = rewrite
    end

    @author = @comment.user
    @article = @comment.article
    @reply = SecureReplyTo.new(Article, @article_id, @to.username)

    thread_parts = [@article.id]
    message_parts = [@comment.id]
    options = list_headers(
      @reply,
      thread_parts,
      message_parts,
      url_for(@comment.url_params)
    ).merge(
      from: "#{@author.display_name} <notifications@coderwall.com>",
      to:   "#{@to.display_name} <#{@to.email}>",
      subject: "Re: #{@article.title}"
    )

    mail(options) do |format|
      format.html { render layout: nil }
    end
  end

  protected

  def prevent_email?(user)
    user.banned_at? ||
      user.email_invalid_at? ||
      user.unsubscribed_comment_emails_at?
  end
end
