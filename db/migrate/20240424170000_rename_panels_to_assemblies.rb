# frozen_string_literal: true

class RenamePanelsToAssemblies < ActiveRecord::Migration[7.1]
  def change
    rename_table :panels, :assemblies
  end
end
