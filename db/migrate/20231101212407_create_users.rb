# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username
      t.text :first_name
      t.text :last_name

      t.timestamps
    end
  end
end
