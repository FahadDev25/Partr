# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :check_2fa_force, only: %i[ new create ]

  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    if params[:body].present?
      return redirect_to root_path
    end

    super do |user|
      org_name = params[:organization_name]
      abbr_name = org_name.split.map { |word| word[0] }.join
      org = Organization.new(name: org_name, abbr_name:)
      org.save!
      team_name = params[:team_name]
      role = TeamRole.create!(role_name: "Default", create_destroy_job: true, all_job: false, all_order: false, all_shipment: false, organization_id: org.id)
      team = Team.new(name: team_name, team_role_id: role.id, organization_id: org.id)
      team.save!

      ActsAsTenant.with_mutable_tenant do
        user.organization_id = org.id
        user.team_id = team.id
        if user.save!
          org.user_id = user.id
          org.save!
        else
          user.errors.merge!(team)
          user.errors.merge!(org)
          team.delete if team
          org.delete if org
        end
      end
      Employee.create(user_id: user.id, organization_id: org.id, is_admin: true)
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  def after_update_path_for(resource)
    home_team_path(current_user.current_team)
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected
    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username, :first_name, :last_name, :organization_name, :team_name, :organization_id, :body])
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [:username, :first_name, :last_name, :po_prefix])
    end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
