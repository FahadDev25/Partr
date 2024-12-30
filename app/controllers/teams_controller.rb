# frozen_string_literal: true

class TeamsController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_team, only: %i[ show edit update destroy home auto_print_orders]
  before_action :authorize, except: %i[ change_team ]

  # GET /teams or /teams.json
  def index
    teams = team_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h)
    if ["", nil].intersect?([params[:order_by], params[:order]])
      teams = team_sort(teams, "is_admin", "DESC")
    else
      teams = team_sort(teams, params[:order_by], params[:order])
    end
    @pagy, @teams = pagy(teams)
  end

  # GET /teams/1 or /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = Team.new
    @team.team_address = Address.new
  end

  # GET /teams/1/edit
  def edit
    @team.team_address = Address.new if @team.team_address.nil?
  end

  # POST /teams or /teams.json
  def create
    if team_params[:order_email_timer_number].present?
      params[:team][:order_received_email_timer] = "#{team_params[:order_email_timer_number]} #{team_params[:order_email_timer_text]}"
    end
    params[:team][:share_jobs_with] = team_params[:share_jobs_with][1..].join(",") if team_params[:share_jobs_with].present?
    params[:team][:share_orders_with] = team_params[:share_orders_with][1..].join(",") if team_params[:share_orders_with].present?
    params[:team][:share_shipments_with] = team_params[:share_shipments_with][1..].join(",") if team_params[:share_shipments_with].present?
    params[:team][:share_parts_with] = team_params[:share_parts_with][1..].join(",") if team_params[:share_parts_with].present?
    @team = Team.new(team_params.except(:order_email_timer_number, :order_email_timer_text))
    @team.address_id = @team.organization&.address_id if @team.use_org_addr
    @team.billing_address_id = @team.organization&.billing_address_id if @team.use_org_billing

    respond_to do |format|
      if @team.save
        @team.copy_org_phone if @team.use_org_phone
        format.html { redirect_to team_url(@team), notice: "Team was successfully created." }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1 or /teams/1.json
  def update
    params[:team][:share_jobs_with] = team_params[:share_jobs_with][1..].join(",") if team_params[:share_jobs_with].present?
    params[:team][:share_orders_with] = team_params[:share_orders_with][1..].join(",") if team_params[:share_orders_with].present?
    params[:team][:share_shipments_with] = team_params[:share_shipments_with][1..].join(",") if team_params[:share_shipments_with].present?
    params[:team][:share_parts_with] = team_params[:share_parts_with][1..].join(",") if team_params[:share_parts_with].present?
    if (team_params[:use_org_addr] == "1") != @team.use_org_addr
      if team_params[:use_org_addr] == "1"
        address = @team.team_address
        @team.update(address_id: @team.organization.address_id)
        address.destroy if address.present? && address != current_tenant.hq_address
      else
        @team.address_id = nil
      end
    end
    if (team_params[:use_org_billing] == "1") != @team.use_org_billing
      if team_params[:use_org_billing] == "1"
        address = @team.billing_address
        @team.update(billing_address_id: @team.organization.billing_address_id)
        address.destroy if address.present?
      else
        @team.billing_address_id = nil
      end
    end

    @team.copy_org_phone if @team.use_org_phone
    if team_params[:order_email_timer_number] != ""
      params[:team][:order_received_email_timer] = "#{team_params[:order_email_timer_number]} #{team_params[:order_email_timer_text]}"
    else
      @team.order_received_email_timer = nil
    end
    respond_to do |format|
      if @team.update(team_params.except(:order_email_timer_number, :order_email_timer_text))
        format.html { redirect_to team_url(@team), notice: "Team was successfully updated." }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1 or /teams/1.json
  def destroy
    @team.destroy!

    respond_to do |format|
      format.html { redirect_to teams_url, notice: "Team was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def address_fields
    set_team if params[:id]
  end

  def auto_print_orders
    if params[:attachment_id].present?
      attachment = Attachment.find_by(id: params[:attachment_id])
      attachment.update(printed: true) if attachment.present?
    end
    @attachment = Attachment.find_by(printed: false, attachable_type: "Order", attachable_id: @team.orders.pluck(:id))
    current_tenant.increment!(:print_count) if @attachment&.file&.representable? && @attachment.file.content_type != "application/pdf"

    render layout: "pdf", locals: { attachment: @attachment, team: @team }
  end

  def change_team
    render partial: "switch_team"
  end

  def home
    current_user.set_current_team(@team) if current_user.current_team != @team
  end

  def optional_part_field_name_field
    set_team if params[:id]
  end

  def phone_field
    set_team if params[:id]
  end

  def job_select
    if params[:value].present?
      team = Team.find(params[:value])
      if params[:object] == "order"
        job_list = helpers.job_select_list(Order.new(team_id: team.id), "none")
      else
        job_list = helpers.job_select_list(team, "none")
      end
    else
      job_list = helpers.job_select_list(nil, "none")
    end
    respond_to do |format|
      format.html { render("jobs/job_select", locals: { job_list:, object: params[:object] }) }
    end
  end

  def project_manager_select
    if params[:value].present?
      team = Team.find(params[:value])
      user_list = helpers.team_member_select_list(team, "none")
    else
      user_list = helpers.team_member_select_list(current_user.current_team, "none")
    end
    respond_to do |format|
      format.html { render("jobs/project_manager_select", locals: { user_list:, object: params[:object] }) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def team_params
      params.require(:team).permit(
        :name, :organization_id, :use_org_addr, :use_org_phone, :phone_number, :assembly_label, :default_unit, :order_email_timer_number, :order_email_timer_text,
        :order_received_email_timer, :show_optional_part_field_1, :show_optional_part_field_2, :optional_part_field_1_name, :optional_part_field_2_name,
        :use_org_billing, :default_tax_rate, :warn, :stale, :enable_manual_line_items, :team_role_id, :address_id, :billing_address_id, :share_jobs_with,
        :share_orders_with, :share_shipments_with, :share_parts_with, send_accounting_notifications_to: [], share_jobs_with: [], share_orders_with: [],
        share_shipments_with: [], share_parts_with: [], team_address_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code],
        billing_address_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code]
      )
    end

    def authorize
      return if current_user.is_admin || TeamMember.find_by(team_id: params[:id], user_id: current_user.id)
      redirect_to request.referrer || home_team_path(current_user.current_team), alert: "You are not authorized to edit #{Team.find(params[:id]).name}"
    end
end
