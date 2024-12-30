# frozen_string_literal: true

class TeamRolesController < ApplicationController
  before_action :set_team_role, only: %i[ show edit update destroy ]
  before_action :authorize

  # GET /team_roles or /team_roles.json
  def index
    @team_roles = TeamRole.all
  end

  # GET /team_roles/1 or /team_roles/1.json
  def show
  end

  # GET /team_roles/new
  def new
    @team_role = TeamRole.new
  end

  # GET /team_roles/1/edit
  def edit
  end

  # POST /team_roles or /team_roles.json
  def create
    @team_role = TeamRole.new(team_role_params)

    respond_to do |format|
      if @team_role.save
        format.html { redirect_to team_role_url(@team_role), notice: "Team role was successfully created." }
        format.json { render :show, status: :created, location: @team_role }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @team_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /team_roles/1 or /team_roles/1.json
  def update
    respond_to do |format|
      if @team_role.update(team_role_params)
        format.html { redirect_to team_role_url(@team_role), notice: "Team role was successfully updated." }
        format.json { render :show, status: :ok, location: @team_role }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @team_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /team_roles/1 or /team_roles/1.json
  def destroy
    if @team_role.teams.any?
      teams = @team_role.teams.pluck(:name).join(", ")
      respond_to do |format|
        format.html { redirect_to @team_role, notice: "Team role cannot be destroyed. Used by: #{teams}." }
      end
    else
      @team_role.destroy!

      respond_to do |format|
        format.html { redirect_to team_roles_url, notice: "Team role was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team_role
      @team_role = TeamRole.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def team_role_params
      params.require(:team_role).permit(:role_name, :organization_id, :create_destroy_job, :all_job, :all_order, :all_shipment)
    end
end
