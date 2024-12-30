# frozen_string_literal: true

class AddJobNumberToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :job_number, :string
  end
end
