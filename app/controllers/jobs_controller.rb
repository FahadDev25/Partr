# frozen_string_literal: true

class JobsController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_job, only: %i[show edit update destroy csv_export part_select_list assembly_select_list address_fields pin unpin]
  before_action :set_team, only: %i[index new create]
  before_action :check_create_destroy_permissions, only: %i[new create destroy]

  # GET /jobs or /jobs.json
  def index
    params[:project_manager] = session[:project_manager] if params[:project_manager].blank?
    params[:status] = session[:status] if params[:status].blank?
    jobs = job_filter(params.except(:controller, :action, :page, :order_by, :order, :team_id).to_unsafe_h)
    jobs = jobs.where(id: @team.jobs.pluck(:id)) unless current_user.current_team.role.all_job
    if ["", nil].intersect?([params[:order_by], params[:order]])
      jobs = job_sort(jobs, "start_date", "DESC")
    else
      jobs = job_sort(jobs, params[:order_by], params[:order])
    end
    @pagy, @jobs = pagy(jobs)
  end

  # GET /jobs/1 or /jobs/1.json
  def show
    current_user.set_current_team(@job.team) if params[:from_search]
    @user = current_user
  end

  # GET /jobs/new
  def new
    @job = Job.new
    @job.jobsite = Address.new
  end

  # GET /jobs/1/edit
  def edit
    @job.jobsite = Address.new if @job.jobsite.nil?
  end

  # POST /jobs or /jobs.json
  def create
    @job = Job.new(job_params.except(:share_with, :job_number_prefix))
    @job.total_cost = 0
    @job.address_id = @job.customer&.address_id if @job.use_cust_addr
    @job.team = current_user.current_team unless current_user.current_team.role.all_job

    respond_to do |format|
      if @job.save
        @job.share_with_teams(job_params[:share_with][1..]) if job_params[:share_with].present?
        format.html { redirect_to job_url(@job), notice: "Job was successfully created." }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1 or /jobs/1.json
  def update
    if (job_params[:use_cust_addr] == "1") != @job.use_cust_addr
      if job_params[:use_cust_addr] == "1"
        address = @job.jobsite
        @job.update(address_id: @job.team.address_id)
        address.destroy if address.present?
      else
        @job.address_id = nil
      end
    end

    respond_to do |format|
      if @job.update(job_params.except(:share_with))
        @job.edit_shared_teams(job_params[:share_with][1..]) if job_params[:share_with].present?
        format.html { redirect_to job_url(@job), notice: "Job was successfully updated." }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1 or /jobs/1.json
  def destroy
    if @job.orders.empty?
      @job.units.each(&:destroy)
      @job.additional_parts.each(&:destroy)
      @job.parts_received.each(&:destroy)
      @job.destroy

      respond_to do |format|
        format.html { redirect_to team_jobs_url(@job.team), notice: "Job was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to job_url(@job), notice: "Cannot destroy job with associated orders." }
        format.json { head :no_content }
      end
    end
  end

  def csv_export
    csv = @job.csv_export

    send_data(csv, filename: "#{@job.name}#{Date.today}.csv")
  end

  def get_vendor_select_list
    vendor_list = { "none" => nil }
    if params[:value] != ""
      job = Job.find(params[:value])
      if (job.assemblies.any? || job.additional_parts.any?) && !job.team.enable_manual_line_items
        vendors = job.vendor_list.reduce(:merge)
      else
        vendors = Vendor.all.pluck(:name, :id)
      end
    else
      vendors = Vendor.all.pluck(:name, :id)
    end

    if vendors
      vendors = vendors.sort_by { |k, _v| k }.to_h
      vendor_list.merge!(vendors)
    end

    respond_to do |format|
      format.html { render("vendors/vendor_select", locals: { vendor_list:, object: params[:object] }) }
    end
  end

  def get_order_select_list
    order_list = { "none" => nil }
    if params[:value] != ""
      job = Job.find(params[:value])
      order_list.merge!((Hash[job.orders.map { |o| [o.name, o.id] }]).sort_by { |k, _v| k }.to_h)
    else
      order_list.merge!((Hash[current_user.current_team.orders.where(job_id: nil).map { |o| [o.name, o.id] }]).sort_by { |k, _v| k }.to_h)
    end

    respond_to do |format|
      format.html { render("orders/order_select", locals: { order_list:, object: params[:object] }) }
    end
  end

  def next_job_number
    render partial: "next_job_number", locals: { job_number: Job.next_job_number(params[:prefix]) }
  end

  def part_select_list
    part_list = { "none" => nil }
    parts = @job.parts_list.reduce(:merge)

    part_list.merge!(parts.sort_by { |k, _v| k }.to_h)

    respond_to do |format|
      format.html { render("parts/part_select", locals: { part_list:, object: params[:object], filter: params[:filter] }) }
    end
  end

  def pin
    PinnedJob.create!(
      organization_id: current_tenant.id,
      team_id: current_user.team_id,
      user_id: current_user.id,
      job_id: @job.id
    )
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @job
      end
    end
  end

  def unpin
    PinnedJob.find_by(
      organization_id: current_tenant.id,
      team_id: current_user.team_id,
      user_id: current_user.id,
      job_id: @job.id
    ).destroy
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @job
      end
    end
  end

  def assembly_select_list
    assembly_list = { "none" => nil }
    part = Part.find_by(id: params[:value])
    assemblies = @job.assembly_list(part).transform_values { |v| [v[:id], v[:sequence]] }

    assembly_list.merge!(assemblies.sort_by { |k, _v| k }.to_h)

    respond_to do |format|
      format.html { render("assemblies/assembly_select", locals: { assembly_list:, object: params[:object], filter: @shipment&.order&.vendor_id }) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id]) if params[:id].present?
    end

    def set_team
      @team = Team.find(params[:team_id])
    end

    # Only allow a list of trusted parameters through.
    def job_params
      params.require(:job).permit(:job_number, :name, :status, :start_date, :deadline, :total_cost, :customer_id, :team_id, :project_manager_id, :use_cust_addr,
        :default_tax_rate, jobsite_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code], share_with: [])
    end

    def check_create_destroy_permissions
      return if current_user.current_team.role.create_destroy_job
      redirect_to request.referrer || team_jobs_path(current_user.current_team), alert: "Team does not have create/destroy job permissions"
    end
end
