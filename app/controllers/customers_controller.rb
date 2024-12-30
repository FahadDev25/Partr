# frozen_string_literal: true

class CustomersController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_customer, only: %i[show edit update destroy]

  # GET /customers or /customers.json
  def index
    customers = customer_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h)
    if ["", nil].intersect?([params[:order_by], params[:order]])
      customers = customer_sort(customers, "name", "ASC")
    else
      customers = customer_sort(customers, params[:order_by], params[:order])
    end
    @pagy, @customers = pagy(customers)
  end

  # GET /customers/1 or /customers/1.json
  def show
    @pagy, @jobs = pagy(@customer.jobs.where(team_id: current_user.current_team.id).order(start_date: :desc))
  end

  # GET /customers/new
  def new
    @customer = Customer.new
    @customer.customer_address = Address.new
  end

  # GET /customers/1/edit
  def edit
    @customer.customer_address = Address.new if @customer.customer_address.nil?
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to customer_url(@customer), notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to customer_url(@customer), notice: "Customer was successfully updated." }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    if @customer.jobs.length.positive?

      respond_to do |format|
        format.html do
          redirect_to customer_url(@customer), notice: "Customer cannot be deleted while it has associated jobs."
        end
        format.json { head :no_content }
      end
    else
      @customer.destroy

      respond_to do |format|
        format.html { redirect_to customers_url, notice: "Customer was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  def csv_export
    uri = URI.parse(request.referrer)
    params = uri.query ? Rack::Utils.parse_query(uri.query).symbolize_keys.except(:controller, :action, :page, :order_by, :order) : {}
    customers = customer_filter(params)
    pdf = Customer.csv_export(customers)

    send_data(pdf, filename: "customers_#{Date.today}.csv")
  end

  def csv_import
    stats = Customer.csv_import(params[:csv_import], current_user.current_team)

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = stats
        @pagy, @customers = pagy(customer_sort(Customer.all, "name", "ASC"), request_path: "/customers")
      }
      format.html { redirect_to customers_url, notice: stats }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:name, :team_id, :phone_number, :po_message, customer_address_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code])
    end
end
