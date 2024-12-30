# frozen_string_literal: true

class AddProjectManagerToJobs < ActiveRecord::Migration[7.1]
  def change
    add_reference :jobs, :project_manager, null: :true, foreign_key: { to_table: :users }
  end
end
