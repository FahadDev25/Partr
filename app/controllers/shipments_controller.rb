# frozen_string_literal: true

class ShipmentsController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_shipment, only: %i[show edit update destroy part_select_list assembly_select_list]
  before_action :set_team, only: %i[index new create]

  # GET /shipments or /shipments.json
  def index
    shipments = shipment_filter(params.except(:controller, :action, :page, :order_by, :order, :team_id).to_unsafe_h)
    shipments = shipments.where(id: @team.shipments.pluck(:id)) unless current_user.current_team.role.all_shipment
    if ["", nil].intersect?([params[:order_by], params[:order]])
      shipments = shipment_sort(shipments, "date_received", "DESC")
    else
      shipments = shipment_sort(shipments, params[:order_by], params[:order])
    end
    @pagy, @shipments = pagy(shipments)
  end

  # GET /shipments/1 or /shipments/1.json
  def show
    current_user.set_current_team(@shipment.team) if params[:from_search]
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
  end

  # GET /shipments/1/edit
  def edit; end

  # POST /shipments or /shipments.json
  def create
    @shipment = Shipment.new(shipment_params.except(:share_with))
    @shipment.team_id = @team.id unless current_user.current_team.role.all_shipment
    @shipment.user_id = current_user.id
    if @shipment.job.present?
      params[:shipment][:share_with] = (Array(params[:shipment][:share_with]) | [@shipment.job.team_id] | @shipment.job.shared_teams.pluck(:id)) - [@shipment.team_id]
    end
    if @shipment.order.present?
      params[:shipment][:share_with] = (Array(params[:shipment][:share_with]) | [@shipment.order.team_id] | @shipment.order.shared_teams.pluck(:id)) - [@shipment.team_id]
    end

    respond_to do |format|
      if @shipment.save
        @shipment.share_with_teams(shipment_params[:share_with][1..]) if shipment_params[:share_with].present?
        ShipmentMailer.orderer_notify(@shipment).deliver_later if @shipment.order&.user
        format.html { redirect_to shipment_url(@shipment), notice: "Shipment was successfully created." }
        format.json { render :show, status: :created, location: @shipment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipments/1 or /shipments/1.json
  def update
    respond_to do |format|
      if @shipment.update(shipment_params.except(:share_with))
        @shipment.edit_shared_teams(shipment_params[:share_with][1..]) if shipment_params[:share_with].present?
        @shipment.parts_received.each { |pr| pr.update(job_id: @shipment.job_id) } if @shipment.job_id_previously_changed?
        format.html { redirect_to shipment_url(@shipment), notice: "Shipment was successfully updated." }
        format.json { render :show, status: :ok, location: @shipment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipments/1 or /shipments/1.json
  def destroy
    @shipment.parts_received.each(&:destroy)
    @shipment.destroy

    respond_to do |format|
      format.html { redirect_to team_shipments_url(@shipment.team), notice: "Shipment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def assembly_select_list
    assembly_list = { "none" => nil }
    part = Part.find_by(id: params[:value])
    if @shipment&.order&.job
      assemblies = @shipment.order.job.assembly_list(part).transform_values { |v| [v[:id], v[:sequence]] }
    elsif part
      assemblies = part.assemblies.map { |assembly| { "#{assembly.name}": { id: assembly.id, sequence: nil } } }.reduce(:merge) || {}
      assemblies = assemblies.transform_values { |v| [v[:id], v[:sequence]] }
    end

    assembly_list.merge!(assemblies.sort_by { |k, _v| k }.to_h) if assemblies

    respond_to do |format|
      format.html { render("assemblies/assembly_select", locals: { assembly_list:, object: params[:object], filter: @shipment&.order&.vendor_id }) }
    end
  end

  def part_select_list
    part_list = { "none" => nil }
    if @shipment.order
      parts = @shipment.order.parts_list.reduce(:merge)
    elsif @shipment.job
      parts = @shipment.job.parts_list.reduce(:merge)
    else
      parts = current_user.current_team.parts.map { |part| { "#{part.label}": part.id } }.reduce(:merge)
    end

    part_list.merge!(parts.sort_by { |k, _v| k }.to_h) if parts

    respond_to do |format|
      format.html { render("parts/part_select", locals: { part_list:, object: params[:object], filter: params[:filter] }) }
    end
  end

  # delete packing slip attachment
  def delete_packing_slip
    @image = ActiveStorage::Attachment.find(params[:image_id])
    @image.purge
    shipment = Shipment.find(params[:shipment_id])

    respond_to do |format|
      format.html { redirect_to edit_shipment_path(shipment) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipment
      @shipment = Shipment.find(params[:id])
    end

    def set_team
      @team = Team.find(params[:team_id])
    end

    # Only allow a list of trusted parameters through.
    def shipment_params
      params.require(:shipment).permit(:from, :shipping_number, :date_received, :notes, :job_id, :order_id, :team_id, attach_packing_slips: [], share_with: [])
    end
end
