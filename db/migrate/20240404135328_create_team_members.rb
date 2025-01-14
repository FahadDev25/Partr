# frozen_string_literal: true

class CreateTeamMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :team_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
