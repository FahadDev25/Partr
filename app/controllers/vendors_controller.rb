# frozen_string_literal: true

class VendorsController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_vendor, only: %i[show edit update destroy]

  # GET /vendors or /vendors.json
  def index
    vendors = vendor_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h)
    if ["", nil].intersect?([params[:order_by], params[:order]])
      vendors = vendor_sort(vendors, "name", "ASC")
    else
      vendors = vendor_sort(vendors, params[:order_by], params[:order])
    end
    @pagy, @vendors = pagy(vendors)
  end

  # GET /vendors/1 or /vendors/1.json
  def show; end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
    @vendor.vendor_address = Address.build
  end

  # GET /vendors/1/edit
  def edit
    @vendor.vendor_address = Address.build if @vendor.vendor_address.nil?
  end

  # POST /vendors or /vendors.json
  def create
    @vendor = Vendor.new(vendor_params)

    respond_to do |format|
      if @vendor.save
        format.html { redirect_to vendor_url(@vendor), notice: "Vendor was successfully created." }
        format.json { render :show, status: :created, location: @vendor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vendors/1 or /vendors/1.json
  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        format.html { redirect_to vendor_url(@vendor), notice: "Vendor was successfully updated." }
        format.json { render :show, status: :ok, location: @vendor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def csv_export
    uri = URI.parse(request.referrer)
    params = uri.query ? Rack::Utils.parse_query(uri.query).symbolize_keys.except(:controller, :action, :page, :order_by, :order) : {}
    vendors = vendor_filter(params)
    csv = Vendor.csv_export(vendors)

    send_data(csv, filename: "vendors_#{Date.today}.csv")
  end

  def csv_import
    stats = Vendor.csv_import(params[:csv_import], current_user.current_team)

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = stats
        @pagy, @vendors = pagy(vendor_sort(Vendor.all, "name", "ASC"), request_path: "/vendors")
      }
      format.html { redirect_to vendors_url, notice: stats }
      format.json { head :no_content }
    end
  end

  # DELETE /vendors/1 or /vendors/1.json
  def destroy
    if @vendor.manufacturers.empty? && @vendor.orders.empty?
      @vendor.destroy

      respond_to do |format|
        format.html { redirect_to vendors_url, notice: "Vendor was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to vendor_url(@vendor), notice: "Cannot destroy Vendor with associate Manufacturers or Orders."
        end
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def vendor_params
      params.require(:vendor).permit(:name, :phone_number, :representative, :team_id, :website, :universal,
        vendor_address_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code])
    end
end
