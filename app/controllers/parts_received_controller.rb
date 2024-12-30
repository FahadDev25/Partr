# frozen_string_literal: true

class PartsReceivedController < ApplicationController
  before_action :set_part_received, only: %i[show edit update destroy]
  after_action :check_received, only: %i[create update destroy]
  # GET /parts_received or /parts_received.json
  def index
    @parts_received = PartReceived.all
  end

  # GET /parts_received/1 or /parts_received/1.json
  def show; end

  # GET /parts_received/new
  def new
    @part_received = PartReceived.new
    @shipment = Shipment.find(params[:shipment_id]) if params[:shipment_id]
    @part_received.line_item_id = params[:line_item_id] if params[:line_item_id]
  end

  # GET /parts_received/1/edit
  def edit; end

  # POST /parts_received or /parts_received.json
  def create
    if part_received_params[:assembly_id]
      id_and_sequence = part_received_params[:assembly_id].gsub(/[\[\]]/, "").split(",")
      id = id_and_sequence[0]
      id_sequence = id_and_sequence[1].to_i != 0 ? id_and_sequence[1..] : nil
      params[:part_received][:assembly_id] = id
      params[:part_received][:id_sequence] = id_sequence
    end
    if part_received_params[:line_item_id]
      line_item = LineItem.find_by(id: part_received_params[:line_item_id])
      params[:part_received][:part_id] = line_item&.part_id
      params[:part_received][:assembly_id] = line_item&.assembly_id
      params[:part_received][:description] = line_item&.description
    end
    @part_received = PartReceived.new(part_received_params)
    @part_received.job_id = @part_received.shipment.job_id if @part_received.shipment_id
    @part_received.user_id = current_user.id

    respond_to do |format|
      if @part_received.save
        @part_received.part.add_stock(@part_received.quantity) if @part_received.shipment && @part_received.shipment.job_id == nil && @part_received.description == nil
        format.html do
          redirect_to @part_received.shipment || @part_received.line_item.order, notice: "Part received was successfully created."
        end
        format.json { render :show, status: :created, location: @part_received }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @part_received.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parts_received/1 or /parts_received/1.json
  def update
    if part_received_params[:assembly_id]
      id_and_sequence = part_received_params[:assembly_id].gsub(/[\[\]]/, "").split(",")
      id = id_and_sequence[0]
      id_sequence = id_and_sequence[1].to_i != 0 ? id_and_sequence[1..] : nil
      params[:part_received][:assembly_id] = id
      @part_received.id_sequence = id_sequence
    end
    if part_received_params[:line_item_id]
      line_item = LineItem.find_by(id: part_received_params[:line_item_id])
      params[:part_received][:part_id] = line_item&.part_id
      params[:part_received][:assembly_id] = line_item&.assembly_id
      params[:part_received][:description] = line_item&.description
    end
    respond_to do |format|
      if @part_received.update(part_received_params)
        format.html do
          redirect_to params[:previous_request], notice: "Part received was successfully updated."
        end
        format.json { render :show, status: :ok, location: @part_received }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @part_received.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parts_received/1 or /parts_received/1.json
  def destroy
    shipment = @part_received.shipment
    @part_received.part.remove_stock(@part_received.quantity) if @part_received.shipment && @part_received.shipment.job_id == nil
    @part_received.destroy

    respond_to do |format|
      format.html { redirect_to shipment || @part_received.line_item.order, notice: "Part received was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_part_received
      @part_received = PartReceived.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def part_received_params
      params.require(:part_received).permit(:shipment_id, :assembly_id, :part_id, :line_item_id, :description, :quantity, id_sequence: [])
    end

    # Check if unit for part received has all parts received
    def check_received
      if @part_received.assembly_id
        assembly_id = @part_received.id_sequence ? @part_received.id_sequence[0] : @part_received.assembly_id
        UnitCheckPartsReceivedJob.perform_later(Unit.find_by(assembly_id:, job_id: @part_received.job_id), current_user.email)
      else
        AdditionalPartsCheckPartsReceivedJob.perform_later(AdditionalPart.find_by(part_id: @part_received.part_id, job_id: @part_received.job_id),
                                                          current_user.email)
      end
    end
end
