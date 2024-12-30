# frozen_string_literal: true

class AdditionalPartsController < ApplicationController
  include Inventory
  before_action :set_additional_part, only: %i[ show edit update destroy parts_received_list parts_ordered_list ]
  after_action :additional_part_check_received, only: %i[ update fill_from_stock]

  # GET /additional_parts or /additional_parts.json
  def index
    @additional_parts = AdditionalPart.all
  end

  # GET /additional_parts/1 or /additional_parts/1.json
  def show
  end

  # GET /additional_parts/new
  def new
    @additional_part = AdditionalPart.new
  end

  # GET /additional_parts/1/edit
  def edit
  end

  # POST /additional_parts or /additional_parts.json
  def create
    if AdditionalPart.new(additional_part_params).valid?
      job = Job.find(additional_part_params[:job_id])
      part = Part.find(additional_part_params[:part_id])
      quantity = additional_part_params[:quantity].to_f

      @additional_part = job.add_part(part, quantity)
    else
      @additional_part = AdditionalPart.new(additional_part_params) # for  getting validation errors
    end

    respond_to do |format|
      if @additional_part&.save
        @additional_part.job.reload
        # format.turbo_stream { flash.now[:notice] = "Additional part was successfully created." }
        format.html { redirect_to job_url(@additional_part.job), notice: "Additional part was successfully created." }
        format.json { render :show, status: :created, location: @additional_part }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @additional_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /additional_parts/1 or /additional_parts/1.json
  def update
    quantity_change = @additional_part.quantity != params[:quantity]
    respond_to do |format|
      if @additional_part.update(additional_part_params)
        @additional_part.job.update_cost if quantity_change
        format.turbo_stream { flash.now[:notice] = "Additional part was successfully updated." }
        format.html { redirect_to job_url(@additional_part.job), notice: "Additional part was successfully updated." }
        format.json { render :show, status: :ok, location: @additional_part }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @additional_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /additional_parts/1 or /additional_parts/1.json
  def destroy
    @additional_part.job.remove_part(@additional_part.part, @additional_part.quantity)

    @additional_part.destroy

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Additional part was successfully destroyed." }
      format.html { redirect_to job_url(@additional_part.job), notice: "Additional part was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def parts_received_list
  end

  # create parts_received for part from inventory
  def fill_from_stock
    @additional_part = AdditionalPart.find(params[:additional_part])
    fill_from_inventory(@additional_part)

    redirect_to job_url(@additional_part.job)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_additional_part
      @additional_part = AdditionalPart.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def additional_part_params
      params.require(:additional_part).permit(:job_id, :part_id, :quantity)
    end

    # Check additional part has receieved >= quantity
    def additional_part_check_received
      AdditionalPartsCheckPartsReceivedJob.perform_later(@additional_part, current_user.email)
    end
end
