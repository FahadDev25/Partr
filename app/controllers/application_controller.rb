# frozen_string_literal: true

class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  # prevent access unless signed in
  before_action :authenticate_user!
  # set tenant
  before_action :set_org_by_user

  before_action :check_2fa_force
  before_action :keep_flash_if_turbo_frame_request

  def keep_flash_if_turbo_frame_request
    flash.keep if turbo_frame_request?
  end

  def after_sign_in_path_for(resource_or_scope)
    current_user.set_current_team unless current_user.current_team
    home_team_path(current_user.current_team)
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_invite_path_for(inviter, invitee)
    users_path
  end

  def after_accept_path_for(resource)
    home_team_path(resource.team_id)
  end

  def authorize
    return if current_user.is_admin
    redirect_to request.referrer || home_team_path(current_user.current_team), alert: "Admins Only"
  end

  def check_2fa_force
    if (current_user.organization.force_2fa || current_user.force_2fa) && !current_user.otp_required_for_login
      redirect_to twofactor_authentication_enable_path, notice: "Your organization has chosen to force two factor authentication"
    end
  end

  def set_org_by_user
    org = current_user&.organization
    set_current_tenant(org)
  end
end
