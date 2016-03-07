class CommentsController < ApplicationController
  before_action :require_login, only: [:create, :destroy]

  def index
    return head(:forbidden) unless admin?
    @comments = Comment.order(created_at: :desc).page(params[:page])
  end

  def spam
    return head(:forbidden) unless admin?
    @comments = Comment.order(created_at: :desc).where("body ILike '%<a %'").page(params[:page])
    render action: 'index'
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if !@comment.save
      flash[:error] = "Your comment did not save. #{@comment.errors.full_messages.join(' ')}"
      flash[:data] = @comment.body
      redirect_to_protip_comment_form
    else
      redirect_to_protip_comment(@comment)
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
    params.require(:comment).permit(:body, :protip_id)
  end
end
