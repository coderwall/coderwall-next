class CommentsController < ApplicationController
  before_action :require_login, only: [:create, :destroy]
  if !Rails.env.test?
    invisible_captcha only: [:create], on_spam: :on_spam_detected
  end

  def index
    respond_to do |format|
      format.html {
        # TODO: do we need this check?
        return head(:forbidden) unless admin?
        @comments = Comment.on_protips.order(created_at: :desc).page(params[:page])
      }
      format.json {
        @comments = Comment.
          where(article_id: params[:article_id]).
          order(created_at: :desc).
          limit(10)

        @comments = @comments.where('created_at < ?', Time.at(params[:before].to_i)) unless params[:before].blank?
      }
    end
  end

  def spam
    return head(:forbidden) unless admin?
    @comments = Comment.order(created_at: :desc).where("body ILike '%<a %'").page(params[:page])
    render action: 'index'
  end

  def show
    @comment = Comment.find(params[:id])
  end

  def create
    if Comment.where(user: current_user).find_by('created_at > ?', ENV.fetch('COMMENTS_THROTTLE', 3).to_i.minutes.ago)
      flash[:error] = "You're posting comments too often, please wait a minute and try again"
      redirect_to_protip_comment_form
      return
    end

    @article = Article.find(comment_params[:article_id])
    @comment = Comment.new(comment_params)
    @comment.user = current_user

    if !@comment.save
      flash[:error] = "Your comment did not save. #{@comment.errors.full_messages.join(' ')}"
      flash[:data] = @comment.body
      redirect_to_protip_comment_form
    else
      @article.subscribe!(current_user)
      notify_comment_added!
      respond_to do |format|
        format.html { redirect_to url_for(@comment.url_params) }
        format.json { render json: json }
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    return head(:forbidden) unless current_user.can_edit?(@comment)
    @comment.destroy
    redirect_to_protip_comment_form
  end

  protected
  def redirect_to_protip_comment(comment)
    redirect_to "#{request.referer}##{comment.dom_id}"
  end

  def redirect_to_protip_comment_form
    redirect_to "#{request.referer}#new-comment"
  end

  def comment_params
    params.require(:comment).permit(:body, :article_id)
  end

  def notify_comment_added!
    # TODO: this won't work for large comments, we should just push the comment id
    json = render_to_string(template: 'comments/_comment.json.jbuilder', locals: {comment: @comment})
    Notification.comment_added!(@article, json, params[:socket_id])

    # TODO: move to job
    email_recipients.each do |to|
      logger.info(event: 'email-notify', email: to, comment: @comment.id)
      CommentMailer.new_comment(to, @comment).deliver_now!
    end
  end

  def email_recipients
    User.where(id: (@article.subscribers - [@comment.user_id]))
  end

  def on_spam_detected
    @article = Article.find(comment_params[:article_id])
    redirect_to protip_path(@article)
  end
end
