# frozen_string_literal: true

json.array! @team_members, partial: "team_members/team_member", as: :team_member
