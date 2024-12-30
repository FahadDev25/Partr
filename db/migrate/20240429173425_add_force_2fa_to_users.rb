# frozen_string_literal: true

class AddForce2faToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :force_2fa, :boolean
  end
end
