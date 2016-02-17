class CommentsController < ApplicationController
  before_action :require_login, only: [:create, :update]

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if !@comment.save
      flash[:error] = "Your comment did not save. #{@comment.errors.full_messages.join(' ')}"
      flash[:data] = @comment.body
      redirect_to request.referer + '#new-comment'
    else
      redirect_to request.referer + "##{@comment.dom_id}"
    end
  end

  protected
  def comment_params
    params.require(:comment).permit(:body, :protip_id)
  end

end
