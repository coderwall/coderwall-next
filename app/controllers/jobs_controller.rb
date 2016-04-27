class JobsController < ApplicationController

  def index
    if [:show_fulltime, :show_parttime, :show_contract].any?{|s| params[s].blank? }
      params[:show_fulltime] = 'true'
      params[:show_parttime] = 'true'
      params[:show_contract] = 'true'
      params[:show_remote] = 'false'
    end
    roles = []
    roles.push(Job::FULLTIME) if params[:show_fulltime] == 'true'
    roles.push(Job::PARTTIME) if params[:show_parttime] == 'true'
    roles.push(Job::CONTRACT) if params[:show_contract] == 'true'
    @jobs = Job.active.order(created_at: :desc)

    @jobs = @jobs.where('jobs.role_type in (?)', roles)
    @jobs = @jobs.where(location: 'Remote') if params[:show_remote] == 'true'
    @jobs = @jobs.where('jobs.location ilike :q or jobs.title ilike :q or jobs.company ilike :q', q: "%#{params[:q]}%") unless params[:q].blank?

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
