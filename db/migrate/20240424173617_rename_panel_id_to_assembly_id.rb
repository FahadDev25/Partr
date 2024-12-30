# frozen_string_literal: true

class RenamePanelIdToAssemblyId < ActiveRecord::Migration[7.1]
  def change
    rename_column      :components, :panel_id, :assembly_id
    rename_column      :parts_received, :panel_id, :assembly_id
    rename_column      :units, :panel_id, :assembly_id
  end
end
