# frozen_string_literal: true

class AddUseCustAddrToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :use_cust_addr, :boolean
  end
end
