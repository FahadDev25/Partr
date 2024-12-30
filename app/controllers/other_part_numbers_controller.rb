# frozen_string_literal: true

class OtherPartNumbersController < ApplicationController
  before_action :set_other_part_number, only: %i[ show edit update destroy ]
  before_action :set_part, only: %i[ index new create ]

  # GET /other_part_numbers or /other_part_numbers.json
  def index
    @other_part_numbers = OtherPartNumber.all
  end

  # GET /other_part_numbers/1 or /other_part_numbers/1.json
  def show
  end

  # GET /other_part_numbers/new
  def new
    @other_part_number = OtherPartNumber.new
  end

  # GET /other_part_numbers/1/edit
  def edit
  end

  # POST /other_part_numbers or /other_part_numbers.json
  def create
    @other_part_number = OtherPartNumber.new(other_part_number_params)
    @other_part_number.company_name = @other_part_number.company.name unless @other_part_number.company_type == "Other"
    @other_part_number.last_price_update = Date.today

    respond_to do |format|
      if @other_part_number.save
        PriceChange.create!(other_part_number_id: @other_part_number.id, date_changed: Date.today, cost_per_unit: @other_part_number.cost_per_unit, organization_id: current_tenant.id) if @other_part_number.cost_per_unit && @other_part_number.cost_per_unit > 0
        @other_part_number.remove_other_primaries if @other_part_number.primary
        format.html { redirect_to part_url(@other_part_number.part), notice: "Other part number was successfully created." }
        format.json { render :show, status: :created, location: @other_part_number }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @other_part_number.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /other_part_numbers/1 or /other_part_numbers/1.json
  def update
    @other_part_number.last_price_update = Date.today if other_part_number_params[:cost_per_unit] != @other_part_number.cost_per_unit

    respond_to do |format|
      if @other_part_number.update(other_part_number_params)
        @other_part_number.update_company_name if @other_part_number.company_id_previously_changed? || @other_part_number.company_type_previously_changed?
        PriceChange.create!(
          other_part_number_id: @other_part_number.id,
          date_changed: Date.today,
          cost_per_unit: @other_part_number.cost_per_unit,
          organization_id: current_tenant.id) if @other_part_number.cost_per_unit_previously_changed?
        if @other_part_number.primary
          @other_part_number.update_part
          @other_part_number.remove_other_primaries
        end
        format.html { redirect_to part_url(@other_part_number.part), notice: "Other part number was successfully updated." }
        format.json { render :show, status: :ok, location: @other_part_number }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @other_part_number.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /other_part_numbers/1 or /other_part_numbers/1.json
  def destroy
    part = @other_part_number.part
    @other_part_number.destroy!

    respond_to do |format|
      format.html { redirect_to part_url(part), notice: "Other part number was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def company_select
    select_list = params[:value] != "Other" ? Object.const_get(params[:value]).all.to_h { |o| [o.name, o.id] }.sort_by { |k, v| k } : nil
    respond_to do |format|
      format.html { render partial: "other_part_numbers/company_select", locals: { company_type: params[:value], select_list:, preset: params[:preset] } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_other_part_number
      @other_part_number = OtherPartNumber.find(params[:id])
    end

    def set_part
      @part = Part.find(params[:part_id])
    end

    # Only allow a list of trusted parameters through.
    def other_part_number_params
      params.require(:other_part_number).permit(:company_type, :company_id, :company_name, :part_number, :part_id, :organization_id, :url, :cost_per_unit, :primary)
    end
end
