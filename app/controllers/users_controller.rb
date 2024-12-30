# frozen_string_literal: true

class UsersController < ApplicationController
  include Search
  include Pagy::Backend
  before_action :set_user, only: %i[ show edit update destroy twofactor_enable twofactor_setup twofactor_verify unlock_account]
  before_action :authorize_admin, except: %i[ edit update ]
  before_action :authorize_edit, only: %i[ edit update ]

  # GET /users or /users.json
  def index
    users = user_filter(params.except(:controller, :action, :page, :order_by, :order).to_unsafe_h).where.not(username: nil)
    if ["", nil].intersect?([params[:order_by], params[:order]])
      users = user_sort(users, "is_admin", "DESC")
    else
      users = user_sort(users, params[:order_by], params[:order])
    end
    @pagy, @users = pagy(users)
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params.except(:is_admin))

    respond_to do |format|
      if @user.save
        Employee.create(user_id: @user.id, is_admin: params[:is_admin])
        format.html { redirect_to user_url(@user), notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    user_params[:is_admin] = false if !current_user.is_admin
    params[:user] = user_params.except(:password, :password_confirmation) if user_params[:password].blank? && user_params[:password_confirmation].blank?
    respond_to do |format|
      if @user.update(user_params.except(:is_admin))
        Employee.find_by(user_id: @user.id, organization_id: current_tenant.id).set_admin(user_params[:is_admin]) if current_user == current_tenant.owner
        format.html { redirect_to current_user.is_admin ? user_url(@user) : root_url, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    employee = Employee.find_by(user_id: @user.id)
    employee&.destroy
    @user.reassign_orders
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  rescue_from "User::Error" do |exception|
    redirect_to users_url, notice: exception.message
  end

  def unlock_account
    @user.unlock_access!

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User account unlocked." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def authorize_admin
      return if current_user.is_admin || current_user == current_tenant.owner
      redirect_to request.referrer || home_team_path(current_user.current_team), alert: "Admins only!"
    end

    def authorize_edit
      return if (current_user.is_admin && !@user.is_admin) || @user == current_user || current_user == current_tenant.owner
      redirect_to request.referrer || home_team_path(current_user.current_team), alert: "You are not authorized to edit this user"
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:username, :first_name, :last_name, :password, :password_confirmation, :email, :is_admin, :organization_name, :team_name,
        :force_2fa, :po_prefix)
    end
end
