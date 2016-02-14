class LikesController < ApplicationController
  before_action :require_login
  before_filter :get_likeable

  def create
    @likeable.create_like!(user: current_user)
    head(:ok)
    # respond_to do |format|
    #   format.js
    # end
  end

  protected
  def get_likeable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        @likeable = $1.classify.constantize.find(value)
      end
    end
  end
end
