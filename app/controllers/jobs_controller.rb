class JobsController < ApplicationController

  def index
    @jobs = Job.active.order(created_at: :desc)
    if params[:posted]
      @jobs = @jobs.where.not(id: params[:posted])
      @featured = Job.find(params[:posted])
    end
  end

  def new
    @job = Job.new
  end

  def show
    @job = Job.find(params[:id])

    JobView.create!(
      job_id: @job.id,
      user_id: current_user.try(:id),
      ip: request.ip
    )

    redirect_to @job.source
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      redirect_to jobs_path(posted: @job.id)
    else
      render action: 'new'
    end
  end

  def publish
    @job = Job.find(params[:job_id])
    @job.charge!(params['stripeToken'])

    flash[:notice] = "Your job is now live"
    redirect_to jobs_path(posted: @job.id)

  rescue Stripe::CardError => e
    flash[:notice] = e.message
    redirect_to new_job_path(@job)
  end

  # private

  def job_params
    params.require(:job).permit(
      :author_email,
      :author_name,
      :company_logo,
      :company_url,
      :company,
      :location,
      :role_type,
      :source,
      :title
    )
  end

end
