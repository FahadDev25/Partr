# frozen_string_literal: true

class CreatePinnedJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :pinned_jobs do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true

      t.timestamps
    end
  end
end
