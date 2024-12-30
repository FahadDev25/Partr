# frozen_string_literal: true

require "test_helper"

class AssemblyTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  require "csv"
  require "tempfile"

  setup do
    @assembly = assemblies(:empty_assembly)
    @user = users(:admin)
    sign_in @user
    ActsAsTenant.current_tenant = organizations(:artificers)
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!

    autocad_csv = CSV.generate do |csv|
      csv << %w[MFG CATALOG QTY DESCRIPTION]
      csv << ["lumthe mad company", "bmc123", "2", "pinching claws"]
      csv << ["Kwalish CO", "whl123", "1", "headlights, waterproof"]
      csv << ["Kwalish CO", "whl123", "1", "headlights, waterproof"]
      csv << ["", "", "1", "headlights, waterproof"]
    end
    @autocad_file = Tempfile.new(["autocad", ".csv"])
    @autocad_file.write(autocad_csv)

    meco_csv = CSV.generate do |csv|
      csv << ["Part Number", "Notes Text", "Unit Qty"]
      csv << ["123abc", " ", "1"]
      csv << ["321cba", "acme gbc101", "1"]
      csv << ["456def", "Warning Label (optional)\nacme #wl55", "1"]
      csv << ["", "Warning Label (optional)", "1"]
    end
    @meco_file = Tempfile.new(["meco", ".csv"])
    @meco_file.write(meco_csv)
  end

  test "should import from autocad csv" do
    @autocad_file.read
    @assembly.csv_import(@autocad_file, "AUTOCAD", @team.organization, @team)
    @autocad_file.close

    component1 = @assembly.components.joins(:part).find_by("parts.mfg_part_number = ?", "bmc123")
    component2 = @assembly.components.joins(:part).find_by("parts.mfg_part_number = ?", "whl123")

    assert_equal(2, @assembly.components.length)
    assert_equal("lum the mad company bmc123", component1.part.label)
    assert_equal("actually made of metal or something", component1.part.description)
    assert_equal(2, component1.quantity)
    assert_equal("Kwalish CO whl123", component2.part.label)
    assert_equal("headlights, waterproof", component2.part.description)
    assert_equal 1, component2.part.other_part_numbers.count
    assert_equal(2, component2.quantity)
  end

  test "should import from meco csv" do
    @meco_file.read
    @assembly.csv_import(@meco_file, "MECO", @team.organization, @team)
    @meco_file.close

    component1 = @assembly.components.joins(:part).find_by("parts.mfg_part_number = ?", "brb101")
    component2 = @assembly.components.joins(:part).find_by("parts.mfg_part_number = ?", "gbc101")
    component3 = @assembly.components.joins(:part).find_by("parts.mfg_part_number = ?", "wl55")

    assert_equal(4, @assembly.components.length)
    assert_equal("ACME brb101", component1.part.label)
    assert_equal("big and red", component1.part.description)
    assert_equal(1, component1.quantity)
    assert_equal("ACME gbc101", component2.part.label)
    assert_equal("just asking to be smashed", component2.part.description)
    assert_equal(1, component2.quantity)
    assert_equal("ACME wl55", component3.part.label)
    assert_equal("Warning Label (optional)\nacme #wl55", component3.part.description)
    assert_equal 2, component3.part.other_part_numbers.count
    assert_equal(1, component3.quantity)
  end
end
