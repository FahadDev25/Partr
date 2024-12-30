# frozen_string_literal: true

class TwofactorAuthenticationController < ApplicationController
  skip_before_action :check_2fa_force

  def enable
    if current_user.otp_required_for_login
      redirect_back fallback_location: home_team_path(current_user.team_id), notice: "Two factor authentication already enabled"
    else
      current_user.otp_secret = User.generate_otp_secret if !current_user.otp_secret
      current_user.save!
      redirect_to twofactor_authentication_setup_path
    end
  end

  def setup
    if current_user.otp_required_for_login
      redirect_back fallback_location: home_team_path(current_user.team_id), notice: "Two factor authentication already enabled"
    end
  end

  def verify
    if current_user.validate_and_consume_otp!(params[:otp])
      current_user.otp_required_for_login = true
      current_user.save!

      codes = current_user.generate_otp_backup_codes!
      current_user.save!

      render "backup_codes", locals: { codes: }, status: :see_other
    else
      redirect_back fallback_location: twofactor_authentication_setup_path, notice: "Invalid OTP"
    end
  end

  def disable
  end

  def validate_disable
    if current_user.validate_and_consume_otp!(params[:otp]) || current_user.invalidate_otp_backup_code!(params[:otp])
      current_user.otp_secret = nil
      current_user.otp_required_for_login = false
      current_user.save!
      redirect_to home_team_path(current_user.current_team), notice: "Two factor authentication successfully disabled"
    else
      redirect_back fallback_location: twofactor_authentication_setup_path, notice: "Invalid OTP"
    end
  end
end
