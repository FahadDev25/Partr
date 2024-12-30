# frozen_string_literal: true

class RemoveComponentFromPartReceived < ActiveRecord::Migration[7.0]
  def change
    remove_column :parts_received, :component_id
  end
end
