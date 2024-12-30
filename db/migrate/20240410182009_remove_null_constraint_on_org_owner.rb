# frozen_string_literal: true

class RemoveNullConstraintOnOrgOwner < ActiveRecord::Migration[7.1]
  def up
    change_column :organizations, :user_id, :bigint, null: true
  end

  def down
    change_column :organizations, :user_id, :bigint, null: false
  end
end
