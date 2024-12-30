# frozen_string_literal: true

class LineItemsController < ApplicationController
  before_action :set_line_item, only: %i[edit update destroy parts_received_list]

  # GET /line_items/new
  def new
    @line_item = LineItem.new
  end

  # GET /line_items/1/edit
  def edit; end

  # POST /line_items or /line_items.json
  def create
    params[:line_item][:cost_per_unit] = Part.find(line_item_params[:part_id]).cost_per_unit if line_item_params[:part_id].present?
    if line_item_params[:assembly_id]
      id_and_sequence = line_item_params[:assembly_id].gsub(/[\[\]]/, "").split(",")
      id = id_and_sequence[0].to_i != 0 ? id_and_sequence[0] : nil
      id_sequence = id_and_sequence[1].to_i != 0 ? id_and_sequence[1..] : nil
      params[:line_item][:assembly_id] = id
      params[:line_item][:id_sequence] = id_sequence
    end
    if LineItem.new(line_item_params).valid? && !line_item_params[:manual]
      order = Order.find(line_item_params[:order_id])
      part = Part.find(line_item_params[:part_id])
      quantity = line_item_params[:quantity].to_i
      assembly = Assembly.find_by(id: line_item_params[:assembly_id])

      @line_item = order.add_part(part, assembly, id_sequence, quantity, line_item_params[:discount], order.organization)
    else
      @line_item = LineItem.new(line_item_params) # gets validation errors
    end
    @line_item.quantity_received = 0
    @line_item.received = false

    respond_to do |format|
      if @line_item.save
        @line_item.set_cost_per_unit unless @line_item.manual
        @line_item.reload
        @line_item.order.update_cost
        format.html { redirect_to order_url(@line_item.order), notice: "Line item was successfully created." }
        format.json { render :show, status: :created, location: @line_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_items/1 or /line_items/1.json
  def update
    if line_item_params[:assembly_id]
      id_and_sequence = line_item_params[:assembly_id].gsub(/[\[\]]/, "").split(",")
      id = id_and_sequence[0].to_i != 0 ? id_and_sequence[0] : nil
      id_sequence = id_and_sequence[1].to_i != 0 ? id_and_sequence[1..] : nil
      params[:line_item][:assembly_id] = id
      @line_item.id_sequence = id_sequence
    end
    quantity_change = @line_item.quantity.to_s != params[:quantity]
    discount_change = @line_item.discount.to_s != params[:discount]
    cost_change = params[:cost_per_unit].present? && @line_item.cost_per_unit.to_s != params[:cost_per_unit]

    respond_to do |format|
      if @line_item.update(line_item_params.except(:update_cost))
        @line_item.set_cost_per_unit if line_item_params[:update_cost] == "1"
        @line_item.reload
        @line_item.order.update_cost if quantity_change || discount_change || cost_change || line_item_params[:update_cost] == "1"
        format.html { redirect_to order_url(@line_item.order), notice: "Line item was successfully updated." }
        format.json { render :show, status: :ok, location: @line_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_items/1 or /line_items/1.json
  def destroy
    if @line_item.parts_received.any?
      respond_to do |format|
        format.html { redirect_to order_url(@line_item.order), notice: "Cannot destroy line item with associated parts received." }
        format.json { head :no_content }
      end
    else
      order = @line_item.order

      @line_item.destroy

      order.remove_part(@line_item.part, @line_item.quantity)

      respond_to do |format|
        format.html { redirect_to order_url(order), notice: "Line item was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  def description_fields
    set_line_item if params[:id]
    set_order if params[:order_id]
  end

  def part_fields
    set_line_item if params[:id]
    set_order if params[:order_id]
    @mode = params[:mode]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end

    def set_order
      @order = Order.find(params[:order_id])
    end

    # Only allow a list of trusted parameters through.
    def line_item_params
      params.require(:line_item).permit(:order_id, :part_id, :quantity, :discount, :assembly_id, :id_sequence, :update_cost, :manual, :description, :cost_per_unit,
        :expected_delivery, :status_location, :om_warranty, :notes, :sku)
    end
end
