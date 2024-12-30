# frozen_string_literal: true

class PartsController < ApplicationController
  include Search
  include Pagy::Backend
  include ActiveModel::Dirty
  before_action :set_part, only: %i[show edit update destroy stock_form modify_stock quick_links]

  # GET /parts or /parts.json
  def index
    parts = part_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h).where(id: current_user.current_team.parts.pluck(:id))
    if ["", nil].intersect?([params[:order_by], params[:order]])
      parts = part_sort(parts, "org_part_number", "ASC")
    else
      parts = part_sort(parts, params[:order_by], params[:order])
    end
    @pagy, @parts = pagy(parts)
  end

  # GET /parts/1 or /parts/1.json
  def show; end

  # GET /parts/new
  def new
    @part = Part.new
  end

  # GET /parts/1/edit
  def edit; end

  # POST /parts or /parts.json
  def create
    @part = Part.new(part_params.except(:share_with))
    @part.last_price_update = Date.today
    @part.team_id = current_user.team_id

    respond_to do |format|
      if @part.save
        @part.share_with_teams(part_params[:share_with][1..]) if part_params[:share_with].present?
        format.turbo_stream { flash.now[:notice] = "Part was successfully created." }
        format.html { redirect_to part_url(@part), notice: "Part was successfully created." }
        format.json { render :show, status: :created, location: @part }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parts/1 or /parts/1.json
  def update
    @part.last_price_update = Date.today if part_params[:cost_per_unit] != @part.cost_per_unit
    respond_to do |format|
      if @part.update(part_params.except(:share_with))
        @part.edit_shared_teams(part_params[:share_with][1..]) if part_params[:share_with].present?
        @part.update_primary_part_number if @part.primary_part_number
        format.turbo_stream { flash.now[:notice] = "Part was successfully updated." }
        format.html { redirect_to part_url(@part), notice: "Part was successfully updated." }
        format.json { render :show, status: :ok, location: @part }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parts/1 or /parts/1.json
  def destroy
    if @part.components.empty? && @part.line_items.empty? && @part.parts_received.empty? && AdditionalPart.where(part_id: @part.id).empty?
      @part.destroy

      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Part was successfully destroyed." }
        format.html { redirect_to parts_url, notice: "Part was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to part_url(@part), notice: "Cannot destroy Part with associated Jobs, Assemblies, Orders, or Shipments."
        end
        format.json { head :no_content }
      end
    end
  end

  def csv_export
    uri = URI.parse(request.referrer)
    params = uri.query ? Rack::Utils.parse_query(uri.query).symbolize_keys.except(:controller, :action, :page, :order_by, :order) : {}
    parts = part_filter(params)
    csv = Part.csv_export(parts)

    send_data(csv, filename: "parts_#{Date.today}.csv")
  end

  def csv_import
    stats = Part.csv_import(params[:csv_import], params[:csv_format], current_user.current_team)

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = stats
        @pagy, @parts = pagy(part_sort(current_user.current_team.parts, "org_part_number", "ASC"), request_path: "/parts")
      }
      format.html do
        redirect_to parts_url, notice: stats
      end
      format.json { head :no_content }
    end
  end

  def toggle_filters
    uri = URI.parse(request.referrer)
    parent_params = uri.query ? Rack::Utils.parse_query(uri.query).symbolize_keys.except(:controller, :action, :page, :order_by, :order) : {}
    @show_filters = params[:show_filters] == "true"
    respond_to do |format|
      format.html { }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("search_and_filters", partial: "parts/search_and_filters",
                locals: { show_filters: !@show_filters, parent_params: })
      end
    end
  end

  def modify_stock
    amount = params[:amount].to_f
    case params[:mode]
    when "Add"
      @part.in_stock += amount
    when "Subtract"
      @part.in_stock -= amount
    when "Set"
      @part.in_stock = amount
    end
    @part.in_stock = 0 if @part.in_stock < 0
    @part.save(validate: false)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("part_#{@part.id}_in_stock", partial: "parts/part_in_stock", locals: { part: @part })
      end
    end
  end

  def qr_codes
    parts = part_filter(params.except(:controller, :action, :page, :order_by, :order)) # For accessing by URL
    render layout: "pdf", locals: { parts: }
  end

  def quick_links
    render layout: "mobile"
  end

  def qr_codes_pdf
    uri = URI.parse(request.referrer)
    params = uri.query ? Rack::Utils.parse_query(uri.query).symbolize_keys.except(:controller, :action, :page, :order_by, :order) : {}
    parts = part_filter(params).where(id: current_user.current_team.parts.pluck(:id))
    pdf = Part.qr_codes_pdf(parts)

    send_data(pdf, filename: "part_qr_codes_#{Date.today}.pdf")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part
      @part = Part.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def part_params
      params.require(:part).permit(:org_part_number, :mfg_part_number, :description, :cost_per_unit, :in_stock, :notes, :optional_field_1, :optional_field_2,
        :manufacturer_id, :unit, :qr_code, :team_id, :url, share_with: [])
    end
end
