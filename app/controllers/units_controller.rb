# frozen_string_literal: true

class UnitsController < ApplicationController
  include Inventory

  before_action :set_unit, only: %i[
    show edit update destroy parts_received_list pdf pdf_export subassembly_parts_received_list parts_ordered_list subassembly_parts_ordered_list
  ]
  before_action :set_job, only: %i[ new ]
  after_action :unit_check_received, only: %i[ update ]

  # GET /units or /units.json
  def index
    @units = Unit.all
  end

  # GET /units/1 or /units/1.json
  def show; end

  # GET /units/new
  def new
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit; end

  # POST /units or /units.json
  def create
    if Unit.new(unit_params).valid?
      job = Job.find(unit_params[:job_id])
      assembly = Assembly.find(unit_params[:assembly_id])
      quantity = unit_params[:quantity].to_i

      @unit = job.add_assembly(assembly, quantity, assembly.organization)
      @unit.received = false
    else
      @unit = Unit.new(unit_params) # for  getting validation errors
    end

    respond_to do |format|
      if @unit&.save
        @unit.job.reload
        # format.turbo_stream { flash.now[:notice] = "Assembly was successfully created." }
        format.html { redirect_to job_url(@unit.job), notice: "Assembly was successfully created." }
        format.json { render :show, status: :created, location: @unit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /units/1 or /units/1.json
  def update
    quantity_change = @unit.quantity != params[:quantity]

    respond_to do |format|
      if @unit.update(unit_params)
        @unit.job.update_cost if quantity_change
        format.turbo_stream { flash.now[:notice] = "Assembly was successfully updated." }
        format.html { redirect_to job_url(@unit.job), notice: "Assembly was successfully updated." }
        format.json { render :show, status: :ok, location: @unit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1 or /units/1.json
  def destroy
    job = @unit.job

    job.remove_assembly(@unit.assembly, @unit.quantity)

    @unit.destroy

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Assembly was successfully removed." }
      format.html { redirect_to job_url(job), notice: "Assembly was successfully removed." }
      format.json { head :no_content }
    end
  end

  # create parts_received for part from inventory
  def fill_from_stock
    unit = Unit.find(params[:unit])
    component = Component.find(params[:component])
    fill_from_inventory(unit, component)

    redirect_to unit_url(unit)
  end

  def subassembly_fill_from_stock
    unit = Unit.find(params[:id])
    component = Component.find(params[:component])
    unit_subassembly = params[:unit_subassembly]
    subassembly_fill_from_inventory(unit, unit_subassembly, component)

    redirect_to unit_url(unit)
  end

  def parts_ordered_list
    @part = Part.find(params[:part_id])
  end

  def parts_received_list
    @part = Part.find(params[:part_id])
  end

  def subassembly_parts_ordered_list
    @part = Part.find(params[:part_id])
    @unit_subassembly = params[:unit_subassembly]
  end

  def subassembly_parts_received_list
    @part = Part.find(params[:part_id])
    @unit_subassembly = params[:unit_subassembly]
  end

  def pdf
    render template: "assemblies/pdf", layout: "pdf", locals: { assembly: @unit.assembly, job: @unit.job, customer: @unit.job.customer }
  end

  def pdf_export
    pdf = @unit.pdf

    send_data(pdf, filename: "#{@unit.assembly.name}_#{@unit.job.name}.pdf")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @unit = Unit.find(params[:id])
    end

    def set_job
      @job = Job.find(params[:job_id])
    end

    # Only allow a list of trusted parameters through.
    def unit_params
      params.require(:unit).permit(:job_id, :assembly_id, :quantity)
    end

    # Check if unit has all parts received
    def unit_check_received
      UnitCheckPartsReceivedJob.perform_later(@unit, current_user.email)
    end
end
