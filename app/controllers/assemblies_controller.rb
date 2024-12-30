# frozen_string_literal: true

class AssembliesController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_assembly, only: %i[show edit update destroy csv_export pdf pdf_export]
  skip_before_action :verify_authenticity_token

  # GET /assemblies or /assemblies.json
  def index
    assemblies = assembly_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h).where(id: current_user.current_team.assemblies.pluck(:id))
    if ["", nil].intersect?([params[:order_by], params[:order]])
      assemblies = assembly_sort(assemblies, "name", "ASC")
    else
      assemblies = assembly_sort(assemblies, params[:order_by], params[:order])
    end
    @pagy, @assemblies = pagy(assemblies)
  end

  # GET /assemblies/1 or /assemblies/1.json
  def show
    components = component_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h)
    components = component_sort(components, params[:order_by], params[:order]) unless ["", nil].intersect?([params[:order_by], params[:order]])
    @pagy, @components = pagy(components)
  end

  # GET /assemblies/new
  def new
    @assembly = Assembly.new
  end

  # GET /assemblies/1/edit
  def edit; end

  # POST /assemblies or /assemblies.json
  def create
    if Assembly.new(assembly_params.except(:import_csv, :csv_format, :share_with)).valid?
      @assembly = Assembly.create(assembly_params.except(:import_csv, :csv_format, :share_with))
      @assembly.csv_import(assembly_params[:import_csv], assembly_params[:csv_format], @assembly.organization, current_user.current_team) if assembly_params[:import_csv]
    else
      @assembly = Assembly.new(assembly_params.except(:import_csv, :csv_format, :share_with))
    end
    @assembly.team_id = current_user.team_id

    respond_to do |format|
      if @assembly.save
        @assembly.share_with_teams(assembly_params[:share_with][1..]) if assembly_params[:share_with].present?
        format.html { redirect_to assembly_url(@assembly), notice: "Assembly was successfully created." }
        format.json { render :show, status: :created, location: @assembly }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @assembly.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assemblies/1 or /assemblies/1.json
  def update
    respond_to do |format|
      if @assembly.update(assembly_params.except(:share_with))
        @assembly.edit_shared_teams(assembly_params[:share_with][1..]) if assembly_params[:share_with].present?
        format.html { redirect_to assembly_url(@assembly), notice: "Assembly was successfully updated." }
        format.json { render :show, status: :ok, location: @assembly }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @assembly.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assemblies/1 or /assemblies/1.json
  def destroy
    if @assembly.units.empty? && @assembly.parts_received.empty?
      @assembly.components.each(&:destroy)
      @assembly.destroy

      respond_to do |format|
        format.html { redirect_to assemblies_url, notice: "Assembly was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to assembly_url(@assembly), notice: "Cannot destroy Assembly with associated Jobs or Shipments" }
        format.json { head :no_content }
      end
    end
  end

  def get_part_select_list
    part_list = { "none" => nil }
    if params[:id] != ""
      assembly = Assembly.find(params[:id])
      if !["", "undefined"].include?(params[:filter])
        parts = assembly.components.joins(part: :manufacturer).where("manufacturers.vendor_id" => params[:filter])
        part_list.merge!((Hash[parts.map { |c| [c.part.label, c.part.id] }]).sort_by { |k, _v| k }.to_h)
      else
        part_list.merge!((Hash[assembly.components.map { |c| [c.part.label, c.part.id] }]).sort_by { |k, _v| k }.to_h)
      end
    elsif params[:alt_value] && params[:alt_url]
      redirect_to "#{params[:alt_url]}?id=#{params[:alt_value]}&object=#{params[:object]}&filter=#{params[:filter]}&preset=#{params[:preset]}"
      return
    end

    respond_to do |format|
      format.html { render("parts/part_select", locals: { part_list:, object: params[:object], filter: params[:filter] }) }
    end
  end

  def pdf
    render layout: "pdf", locals: { assembly: @assembly, job: nil, customer: @assembly.customer }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assembly
      @assembly = Assembly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def assembly_params
      params.require(:assembly).permit(:name, :import_csv, :csv_format, :team_id, :notes, :customer_id, share_with: [])
    end
end
