# frozen_string_literal: true

class ReplaceTeamAddressWithReference < ActiveRecord::Migration[7.1]
  def up
    add_reference :teams, :address, null: true, foreign_key: true
    Team.all.each do |team|
      next unless team.address.present? || team.address2.present? || team.city.present? || team.state.present? || team.zip_code.present?
      address = team.use_org_addr ? team.organization.hq_address
                                  : Address.create(
                                    address_1: team.address,
                                    address_2: team.address2,
                                    city: team.city,
                                    state: team.state,
                                    zip_code: team.zip_code,
                                    organization_id: team.organization_id
                                  )
      team.address_id = address.id
      team.save!
    end
    remove_column :teams, :address
    remove_column :teams, :address2
    remove_column :teams, :city
    remove_column :teams, :state
    remove_column :teams, :zip_code
  end

  def down
    add_column :teams, :address, :string
    add_column :teams, :address2, :string
    add_column :teams, :city, :string
    add_column :teams, :state, :string
    add_column :teams, :zip_code, :string
    Team.all.each do |team|
      next unless team.team_address.present?
      team.address = team.team_address.address_1
      team.address2 = team.team_address.address_2
      team.city = team.team_address.city
      team.state = team.team_address.state
      team.zip_code = team.team_address.zip_code
      team.save!
    end
    remove_reference :teams, :address
  end
end
