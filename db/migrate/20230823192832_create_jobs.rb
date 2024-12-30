# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.string :name
      t.string :status
      t.date :start_date
      t.date :deadline
      t.decimal :total_cost
      t.belongs_to :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
