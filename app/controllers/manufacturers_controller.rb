# frozen_string_literal: true

class ManufacturersController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_manufacturer, only: %i[show edit update destroy]

  # GET /manufacturers or /manufacturers.json
  def index
    manufacturers = manufacturer_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h)
    if ["", nil].intersect?([params[:order_by], params[:order]])
      manufacturers = manufacturer_sort(manufacturers, "name", "ASC")
    else
      manufacturers = manufacturer_sort(manufacturers, params[:order_by], params[:order])
    end
    @pagy, @manufacturers = pagy(manufacturers)
  end

  # GET /manufacturers/1 or /manufacturers/1.json
  def show; end

  # GET /manufacturers/new
  def new
    @manufacturer = Manufacturer.new
  end

  # GET /manufacturers/1/edit
  def edit; end

  # POST /manufacturers or /manufacturers.json
  def create
    @manufacturer = Manufacturer.new(manufacturer_params)

    respond_to do |format|
      if @manufacturer.save
        format.html { redirect_to manufacturer_url(@manufacturer), notice: "Manufacturer was successfully created." }
        format.json { render :show, status: :created, location: @manufacturer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manufacturers/1 or /manufacturers/1.json
  def update
    respond_to do |format|
      if @manufacturer.update(manufacturer_params)
        format.html { redirect_to manufacturer_url(@manufacturer), notice: "Manufacturer was successfully updated." }
        format.json { render :show, status: :ok, location: @manufacturer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manufacturers/1 or /manufacturers/1.json
  def destroy
    if @manufacturer.parts.empty?
      @manufacturer.destroy

      respond_to do |format|
        format.html { redirect_to manufacturers_url, notice: "Manufacturer was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to manufacturer_url(@manufacturer), notice: "Cannot destroy Manufacturer with associated parts."
        end
        format.json { head :no_content }
      end
    end
  end

  def csv_export
    uri = URI.parse(request.referrer)
    params = uri.query ? Rack::Utils.parse_query(uri.query).symbolize_keys.except(:controller, :action, :page, :order_by, :order) : {}
    manufacturers = manufacturer_filter(params)
    pdf = Manufacturer.csv_export(manufacturers)

    send_data(pdf, filename: "manufacturers_#{Date.today}.csv")
  end

  def csv_import
    stats = Manufacturer.csv_import(params[:csv_import], current_user.current_team)

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = stats
        @pagy, @manufacturers = pagy(manufacturer_sort(Manufacturer.all, "name", "ASC"), request_path: "/manufacturers")
      }
      format.html { redirect_to manufacturers_url, notice: stats }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manufacturer
      @manufacturer = Manufacturer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def manufacturer_params
      params.require(:manufacturer).permit(:name, :vendor_id, :team_id)
    end
end
