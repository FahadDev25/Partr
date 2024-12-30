# frozen_string_literal: true

class AddTeamRoleToTeams < ActiveRecord::Migration[7.1]
  def up
    add_reference :teams, :team_role, null: true, foreign_key: true
    Organization.all.each do |org|
      default_role = TeamRole.create_with(
        create_destroy_job: true,
        all_job: false,
        all_order: false,
        all_shipment: false).find_or_create_by!(organization_id: org.id, role_name: "Default")
      Team.where(organization_id: org.id).each do |team|
        team.update!(team_role_id: default_role.id)
      end
    end
    change_column_null :teams, :team_role_id, false
  end

  def down
    remove_reference :teams, :team_role
  end
end
