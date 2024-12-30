# frozen_string_literal: true

class AddTeamToTables < ActiveRecord::Migration[7.1]
  def up
    Team.create(name: "Team", organization_id: User.any? ? Organization.first.id : nil) unless Team.any? || !User.any?
    add_reference :jobs, :team, null: false, foreign_key: true, default: Team.any? ? Team.any? ? Team.first.id : nil : nil
    change_column :jobs, :team_id, :bigint, default: nil
    add_reference :orders, :team, null: false, foreign_key: true, default: Team.any? ? Team.first.id : nil
    change_column :orders, :team_id, :bigint, default: nil
    add_reference :shipments, :team, null: false, foreign_key: true, default: Team.any? ? Team.first.id : nil
    change_column :shipments, :team_id, :bigint, default: nil
    add_reference :panels, :team, null: false, foreign_key: true, default: Team.any? ? Team.first.id : nil
    change_column :panels, :team_id, :bigint, default: nil
    add_reference :parts, :team, null: false, foreign_key: true, default: Team.any? ? Team.first.id : nil
    change_column :parts, :team_id, :bigint, default: nil
    add_reference :manufacturers, :team, null: false, foreign_key: true, default: Team.any? ? Team.first.id : nil
    change_column :manufacturers, :team_id, :bigint, default: nil
    add_reference :vendors, :team, null: false, foreign_key: true, default: Team.any? ? Team.first.id : nil
    change_column :vendors, :team_id, :bigint, default: nil
    add_reference :customers, :team, null: false, foreign_key: true, default: Team.any? ? Team.first.id : nil
    change_column :customers, :team_id, :bigint, default: nil
  end

  def down
    remove_reference :jobs, :team
    remove_reference :orders, :team
    remove_reference :shipments, :team
    remove_reference :panels, :team
    remove_reference :parts, :team
    remove_reference :manufacturers, :team
    remove_reference :vendors, :team
    remove_reference :customers, :team
  end
end
