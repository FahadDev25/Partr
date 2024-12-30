# frozen_string_literal: true

class RemoveDefaultOrg < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :organization_id, :bigint, default: nil
    change_column :parts, :organization_id, :bigint, default: nil
    change_column :components, :organization_id, :bigint, default: nil
    change_column :manufacturers, :organization_id, :bigint, default: nil
    change_column :panels, :organization_id, :bigint, default: nil
  end

  def down
  end
end
