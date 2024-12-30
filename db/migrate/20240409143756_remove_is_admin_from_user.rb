# frozen_string_literal: true

class RemoveIsAdminFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :is_admin
  end
end
