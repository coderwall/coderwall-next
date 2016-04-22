class JobsController < ApplicationController

  def index
    @jobs = Job.active.all
  end

  def show
    redirect_to Job.find(params[:id]).source
  end

end
