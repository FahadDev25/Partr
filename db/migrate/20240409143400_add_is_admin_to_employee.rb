# frozen_string_literal: true

class AddIsAdminToEmployee < ActiveRecord::Migration[7.1]
  def up
    add_column :employees, :is_admin, :boolean
    Employee.all.each do |e|
      e.is_admin = e.user.is_admin
    end
  end

  def down
    remove_column :employees, :is_admin
  end
end
