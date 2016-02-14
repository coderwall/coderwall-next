class LikesController < ApplicationController
  before_action :require_login

  def create
    @likeable = find_likeable
    @likeable.likes.create!(user: current_user) unless current_user.likes?(@likeable)
    respond_to do |format|
      format.js { head(:ok) }
    end
  end

  protected
  def find_likeable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        klass = $1.classify.constantize
        if klass == Protip
          return klass.find_by_public_id!(value)
        else
          return klass.find(value)
        end
      end
    end
  end
end
