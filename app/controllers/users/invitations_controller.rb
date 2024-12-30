# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  skip_before_action :check_2fa_force, only: %i[ edit update ]
  before_action :configure_permitted_parameters, if: :devise_controller?

  def create
    super do |user|
      Employee.create(organization_id: user.organization_id, user_id: user.id, is_admin: params[:is_admin])
    end
  end

  def update
    super do |user|
      TeamMember.create(organization_id: user.organization_id, team_id: user.team_id, user_id: user.id)
    end
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:invite, keys: [:username, :team_id, :is_admin, :force_2fa])
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [:first_name, :last_name])
    end
end
