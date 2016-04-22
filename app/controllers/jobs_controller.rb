class JobsController < ApplicationController

  def show
    @job = Job.order("RANDOM()").first
  end

end
