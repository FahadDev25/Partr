# frozen_string_literal: true

class SubassembliesController < ApplicationController
  before_action :set_subassembly, only: %i[ show edit update destroy ]
  after_action :update_parent_totals, only: %i[ create update destroy ]

  # GET /subassemblies or /subassemblies.json
  def index
    @subassemblies = Subassembly.all
  end

  # GET /subassemblies/1 or /subassemblies/1.json
  def show
  end

  # GET /subassemblies/new
  def new
    @subassembly = Subassembly.new
  end

  # GET /subassemblies/1/edit
  def edit
  end

  # POST /subassemblies or /subassemblies.json
  def create
    if Subassembly.new(subassembly_params).valid?
      parent_assembly = Assembly.find(subassembly_params[:parent_assembly_id])
      child_assembly = Assembly.find(subassembly_params[:child_assembly_id])
      quantity = subassembly_params[:quantity].to_i

      @subassembly = parent_assembly.add_subassembly(child_assembly, quantity, parent_assembly.organization)
    else
      @subassembly = Subassembly.new(subassembly_params) # gets validation errors
    end

    respond_to do |format|
      if @subassembly.save
        format.html { redirect_to assembly_url(@subassembly.parent_assembly), notice: "Subassembly was successfully created." }
        format.json { render :show, status: :created, location: @subassembly }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @subassembly.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subassemblies/1 or /subassemblies/1.json
  def update
    respond_to do |format|
      if @subassembly.update(subassembly_params)
        format.html { redirect_to assembly_url(@subassembly.parent_assembly), notice: "Subassembly was successfully updated." }
        format.json { render :show, status: :ok, location: @subassembly }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @subassembly.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subassemblies/1 or /subassemblies/1.json
  def destroy
    assembly = @subassembly.parent_assembly
    @subassembly.destroy!

    respond_to do |format|
      format.html { redirect_to assembly_url(assembly), notice: "Subassembly was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def child_assembly_select_list
    if params[:value] != ""
      assemblies = current_user.current_team.assemblies.where.not(id: params[:value])
    else
      assemblies = current_user.current_team.assemblies
    end
    assembly_list = (Hash[assemblies.map { |a| [a.name, a.id] }]).sort_by { |k, _v| k }.to_h

    respond_to do |format|
      format.html { render("child_assembly_select", locals: { assembly_list:, object: params[:object], filter: nil }) }
    end
  end

  def update_parent_totals
    @subassembly.parent_assembly.update_totals
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subassembly
      @subassembly = Subassembly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subassembly_params
      params.require(:subassembly).permit(:parent_assembly_id, :child_assembly_id, :team_id, :quantity)
    end
end
