class CommentsController < ApplicationController
  before_action :require_login, only: [:create, :destroy]

  def index
    return head(:forbidden) unless admin?
    respond_to do |format|
      format.html { @comments = Comment.order(created_at: :desc).page(params[:page]) }
      format.json {
        @comments = Comment.
          where(article_id: params[:article_id]).
          order(created_at: :desc).
          limit(10)

        @comments = @comments.where('created_at < ?', params[:before]) unless params[:before].blank?
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
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if !@comment.save
      flash[:error] = "Your comment did not save. #{@comment.errors.full_messages.join(' ')}"
      flash[:data] = @comment.body
      redirect_to_protip_comment_form
    else
      json = render_to_string(template: 'comments/_comment.json.jbuilder', locals: {comment: @comment})
      Pusher.trigger(@comment.article.dom_id.to_s, 'new-comment', json, {
        socket_id: params[:socket_id]
      })
      respond_to do |format|
        format.html { redirect_to_protip_comment(@comment) }
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
end
