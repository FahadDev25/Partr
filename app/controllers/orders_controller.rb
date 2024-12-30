# frozen_string_literal: true

class OrdersController < ApplicationController
  include PoHelper
  include Search
  include Pagy::Backend

  before_action :set_order, only: %i[show edit update destroy csv_export pdf_export po]
  before_action :set_team, only: %i[index new create]

  # GET /orders or /orders.json
  def index
    params[:created_by] = session[:created_by] if params[:created_by].blank?
    orders = order_filter(params.except(:controller, :action, :page, :order_by, :order, :team_id).to_unsafe_h)
    orders = orders.where(id: @team.orders.pluck(:id)) unless current_user.current_team.role.all_order
    if ["", nil].intersect?([params[:order_by], params[:order]])
      orders = order_sort(orders, "created_at", "DESC")
    else
      orders = order_sort(orders, params[:order_by], params[:order])
    end
    if params[:order_by] == "parts_received"
      @pagy, @orders = pagy_array(orders)
    else
      @pagy, @orders = pagy(orders)
    end
  end

  # GET /orders/1 or /orders/1.json
  def show
    current_user.set_current_team(@order.team) if params[:from_search]
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.ship_to = Address.new
    @order.billing_address = Address.new
  end

  # GET /orders/1/edit
  def edit
    @order.ship_to = Address.new if @order.ship_to.nil?
    @order.billing_address = Address.new if @order.billing_address.nil?
  end

  # POST /orders or /orders.json
  def create
    @order = Order.new(order_params.except(:for_all, :po_prefix, :share_with))
    @order.po_number = next_po_number(order_params[:po_prefix])
    @order.user_id = current_user.id
    @order.billing_address = @order.ship_to if @order.use_ship_for_bill
    @order.team_id = @team.id unless current_user.current_team.role.all_order
    if @order.job.present?
      params[:order][:share_with] = (Array(params[:order][:share_with]) | [@order.job.team_id] | @order.job.shared_teams.pluck(:id)) - [@order.team_id]
    end
    @order.quantity_received = 0
    @order.total_quantity = 0
    @order.received = false
    respond_to do |format|
      if @order.save
        @order.share_with_teams(order_params[:share_with][1..]) if order_params[:share_with].present?
        CheckOrderPartsReceivedJob.set(
          wait: current_user.current_team.order_email_timer_seconds
        ).perform_later(@order, current_user.email) if current_user.current_team.order_received_email_timer
        @order.update_total_cost
        if order_params[:for_all] == "1" && order_params[:job_id] != "" && order_params[:vendor_id] != ""
          @order.add_all_parts_from_vendor
          @order.update_cost
        end
        OrderMailer.reimbursement_notify(@order).deliver_later(wait: 30.minutes) if @order.needs_reimbursement
        format.html { redirect_to order_url(@order), notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    if (order_params[:use_ship_for_bill] == "1") != @order.use_ship_for_bill
      if order_params[:use_ship_for_bill] == "1"
        address = @order.billing_address
        @order.update(billing_address_id: @order.address_id)
        address.destroy if address.present?
      else
        @order.billing_address_id = nil
      end
    end
    needs_reimbursement = ((order_params[:needs_reimbursement] == "1") != @order.needs_reimbursement) && order_params[:needs_reimbursement] == "1"

    update_cost = @order.tax_rate != order_params[:tax_rate].to_f && @order.line_items.length > 0 && @order.tax_total == order_params[:tax_total].to_f
    respond_to do |format|
      if @order.update(order_params.except(:share_with))
        @order.edit_shared_teams(order_params[:share_with][1..]) if order_params[:share_with].present?
        @order.update_cost if update_cost
        @order.update_total_cost
        OrderMailer.reimbursement_notify(@order).deliver_later(wait: 30.minutes) if needs_reimbursement
        format.html { redirect_to order_url(@order), notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    if @order.shipments.empty?
      @order.line_items.each(&:destroy)
      @order.destroy

      respond_to do |format|
        format.html { redirect_to team_orders_url(@order.team), notice: "Order was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to order_url(@order), notice: "Cannot destroy Order with associated Shipments." }
        format.json { head :no_content }
      end
    end
  end

  def assembly_select_list
    assembly_list = { "none" => [nil, []] }
    order = Order.find(params[:id])
    if !["undefined", ""].include? params[:value]
      part = Part.find(params[:value])
      assemblies = order.unordered_assemblies(part, params[:mode])&.reduce(:merge)&.transform_values { |v| [v[:id], v[:sequence]] } || {}

      assembly_list.merge!(assemblies.sort_by { |k, _v| k }.to_h)
    else
    end

    respond_to do |format|
      format.html { render("assemblies/assembly_select", locals: { assembly_list:, object: params[:object], filter: @shipment&.order&.vendor_id }) }
    end
  end

  # get the next PO number based on the prefix parameter
  def next_po
    po = next_po_number(params[:prefix])
    respond_to do |format|
      format.html { render("orders/next_po_number", locals: { po: }) }
    end
  end

  def part_select_list
    part_list = { "none" => nil }
    if params[:value] != "undefined"
      order = Order.find(params[:id])
      parts = order.unordered_parts(params[:mode]).reduce(:merge)&.transform_values { |v| v[:id] }

      parts = parts&.sort_by { |k, _v| k }.to_h
      part_list.merge!(parts)
    else
      part_list.merge!((Hash[current_user.current_team.parts.map { |p| [p.label, p.id] }]).sort_by { |k, _v| k }.to_h)
    end

    respond_to do |format|
      format.html { render("parts/part_select", locals: { part_list:, object: params[:object] }) }
    end
  end

  def po
    render layout: "pdf",
      locals: {
        order: @order,
        format: { type: "Purchase Order", type_abbr: "PO", show_prices: true },
        options: { include_job_name: "1", include_job_number: "1" }
      }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    def set_team
      @team = Team.find(params[:team_id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:parts_cost, :order_date, :vendor_id, :job_id, :for_all, :po_number, :tax_rate, :tax_total, :freight_cost, :notes, :po_prefix,
        :team_id, :date_paid, :amount_paid, :payment_method, :payment_confirmation, :mark_line_items_received, :include_in_bom, :quote_number, :fob, :use_ship_for_bill,
        :needs_reimbursement,
        ship_to_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code], billing_address_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code],
        share_with: [])
    end
end
