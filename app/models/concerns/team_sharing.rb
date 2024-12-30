# frozen_string_literal: true

module TeamSharing
  extend ActiveSupport::Concern

  included do
    has_many :shared_records, as: :shareable
    has_many :shared_teams, source: :team, through: :shared_records

    def share_with_teams(team_ids)
      team_ids.each do |add_id|
        SharedRecord.create!(
          shareable_type: self.class.to_s,
          shareable_id: id,
          team_id: add_id,
          organization_id:
        )
      end
    end

    def edit_shared_teams(team_ids)
      shared_team_ids = shared_teams.pluck(:id)
      SharedRecord.where(shareable_type: self.class.to_s, shareable_id: id, team_id: (shared_team_ids - team_ids)).delete_all
      (team_ids - shared_team_ids).each do |add_id|
        SharedRecord.create!(
          shareable_type: self.class.to_s,
          shareable_id: id,
          team_id: add_id,
          organization_id:,
        )
      end
    end
  end
end
