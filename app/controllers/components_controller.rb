# frozen_string_literal: true

class ComponentsController < ApplicationController
  before_action :set_component, only: %i[show edit update destroy]
  after_action :unit_check_received, only: %i[update delete]

  # GET /assemblies/:id/components or /assemblies/:id/components.json
  def index
    @components = Component.all
  end

  # GET /assemblies/:id/components/1 or /assemblies/:id/components/1.json
  def show; end

  # GET /assemblies/:id/components/new
  def new
    @component = Component.new
    @assembly = Assembly.find(params[:assembly_id]) if params[:assembly_id]
  end

  # GET /assemblies/:id/components/1/edit
  def edit; end

  # POST /assemblies/:id/components or /assemblies/:id/components.json
  def create
    if Component.new(component_params).valid?
      part = Part.find(component_params[:part_id])
      assembly = Assembly.find(component_params[:assembly_id])
      quantity = component_params[:quantity].to_i

      @component = assembly.add_part(part, quantity, assembly.organization)
    else
      @component = Component.new(component_params) # gets validation errors
    end

    respond_to do |format|
      if @component.save
        format.html { redirect_to assembly_url(@component.assembly), notice: "Component was successfully created." }
        format.json { render :show, status: :created, location: @component }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assemblies/:id/components/1 or /assemblies/:id/components/1.json
  def update
    respond_to do |format|
      if @component.update(component_params)
        format.html { redirect_to assembly_url(@component.assembly), notice: "Component was successfully updated." }
        format.json { render :show, status: :ok, location: @component }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assemblies/:id/components/1 or /assemblies/:id/components/1.json
  def destroy
    assembly = @component.assembly
    @component.destroy!

    respond_to do |format|
      format.html { redirect_to assembly_url(assembly), notice: "Component was successfully destroyed." }
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
        render turbo_stream: turbo_stream.replace("search_and_filters", partial: "assemblies/component_search_filters",
                locals: { show_filters: !@show_filters, parent_params: })
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_component
      @component = Component.find(params[:id])
      @assembly = @component.assembly
    end

    # Only allow a list of trusted parameters through.
    def component_params
      params.require(:component).permit(:part_id, :assembly_id, :quantity)
    end

    # Check if units for assembly have all parts received
    def unit_check_received
      Unit.where(assembly_id: @component.assembly_id).each do |c|
        UnitCheckPartsReceivedJob.perform_later(c)
      end
    end
end
