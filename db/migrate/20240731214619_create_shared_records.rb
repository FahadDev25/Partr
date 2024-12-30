# frozen_string_literal: true

class CreateSharedRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :shared_records do |t|
      t.references :shareable, null: false, polymorphic: true
      t.references :team, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
