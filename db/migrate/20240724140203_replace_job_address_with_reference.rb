# frozen_string_literal: true

class ReplaceJobAddressWithReference < ActiveRecord::Migration[7.1]
  def up
    add_reference :jobs, :address, null: true, foreign_key: true
    Job.all.each do |job|
      next unless job.address_1.present? || job.address_2.present? || job.city.present? || job.state.present? || job.zip_code.present?
      address = Address.create(
          address_1: job.address_1,
          address_2: job.address_2,
          city: job.city,
          state: job.state,
          zip_code: job.zip_code,
          organization_id: job.organization_id
        )
      job.address_id = address.id
      job.save!
    end
    remove_column :jobs, :address_1
    remove_column :jobs, :address_2
    remove_column :jobs, :city
    remove_column :jobs, :state
    remove_column :jobs, :zip_code
  end

  def down
    add_column :jobs, :address_1, :string
    add_column :jobs, :address_2, :string
    add_column :jobs, :city, :string
    add_column :jobs, :state, :string
    add_column :jobs, :zip_code, :string
    Job.all.each do |job|
      next unless job.jobsite.present?
      job.address_1 = job.jobsite.address_1
      job.address_2 = job.jobsite.address_2
      job.city = job.jobsite.city
      job.state = job.jobsite.state
      job.zip_code = job.jobsite.zip_code
      job.save!
    end
    remove_reference :jobs, :address
  end
end
