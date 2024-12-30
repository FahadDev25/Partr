# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[ show edit update destroy ]
  before_action :authorize

  # no index of organizations
  # GET /organizations or /organizations.json
  # def index
  #   @organizations = Organization.all
  # end

  # GET /organizations/1 or /organizations/1.json
  def show
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
    @organization.hq_address = Address.new
    @organization.billing_address = Address.new
  end

  # GET /organizations/1/edit
  def edit
    @organization.hq_address = Address.new if @organization.hq_address.nil?
    @organization.billing_address = Address.new if @organization.billing_address.nil?
  end

  # POST /organizations or /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to organization_url(@organization), notice: "Organization was successfully created." }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1 or /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        if @organization.previous_changes.has_key? :phone_number
          @organization.teams.where(use_org_phone: true).each do |team|
            team.copy_org_phone
          end
        end
        format.html { redirect_to organization_url(@organization), notice: "Organization was successfully updated." }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1 or /organizations/1.json
  def destroy
    @organization.destroy!

    respond_to do |format|
      format.html { redirect_to organizations_url, notice: "Organization was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def organization_params
      params.require(:organization).permit(:name, :abbr_name, :user_id, :phone_number, :logo, :force_2fa, :mcmaster_certificate, :mcmaster_password, :mcmaster_username,
        :fax_number, :job_number_prefix,
        hq_address_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code], billing_address_attributes: [:id, :address_1, :address_2, :city, :state, :zip_code])
    end

    def authorize
      return if current_user.is_admin && current_user&.owned_org&.id&.to_s == params[:id]
      redirect_to request.referrer || home_team_path(current_user.current_team), alert: "You are not authorized to access this organization"
    end
end
