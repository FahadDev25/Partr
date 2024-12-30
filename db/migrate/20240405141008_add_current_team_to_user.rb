# frozen_string_literal: true

class AddCurrentTeamToUser < ActiveRecord::Migration[7.1]
  def up
    add_reference :users, :team, foreign_key: true

    if User.any?
      team = Team.first
      User.all.each do |u|
        u.set_current_team(team)
        TeamMember.create(organization_id: u.organization_id, team_id: team.id, user_id: u.id)
        Employee.create(organization_id: u.organization_id, user_id: u.id)
      end
    end
  end

  def down
    remove_reference :users, :team
  end
end
