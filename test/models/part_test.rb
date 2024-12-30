# frozen_string_literal: true

require "test_helper"

class PartTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  require "csv"
  require "tempfile"

  setup do
    @part1 = parts(:big_red_button)
    @part2 = parts(:glass_pane)
    @user = users(:admin)
    sign_in @user
    ActsAsTenant.current_tenant = organizations(:artificers)
    @user.current_team = @team = teams(:trapsmiths)
    @user.save!

    appsheet_csv = CSV.generate(encoding: "utf-8") do |csv|
      csv << ["Part Number", "MECO Part Number", "Manufacturer", "Vendor", "Cost per Unit", "Description", "Notes", "In Stock", "UL File Number", "UL CCN"]
      csv << ["", "123abc", "", "", "40.00", "new description", "new notes", "", "555444", "444555"]
      csv << ["gbc101", "", "ACME", "Warner Brothers", "40.00", "new description", "new notes", "", "888777", "777888"]
      csv << ["", "555aaa", "", "", "0.5", "", "", "1", "", ""]
      csv << ["456def", "abc123", "morp", "florp", "3.50", "Warning Label (optional)\nacme #wl55", "notes", "12", "222111", "111222"]
    end
    @appsheet_file = Tempfile.new(["appsheet", ".csv"])
    @appsheet_file.write(appsheet_csv)
  end
  test "should import from appsheet csv" do
    @appsheet_file.read
    output = Part.csv_import(@appsheet_file, "Appsheet", @team)
    @appsheet_file.close

    @part1.reload
    @part2.reload

    assert_equal "Parts Read: 4 | Parts Modified: 2 | Parts Added: 2 | Manufacturers Added: 1 | Vendors Added: 1", output
    assert_equal "morp", Manufacturer.last.name
    assert_equal "florp", Vendor.last.name

    assert_equal 40, @part1.cost_per_unit
    assert_equal "new description", @part1.description
    assert_equal "new notes", @part1.notes
    assert_equal "555444", @part1.optional_field_1
    assert_equal "444555", @part1.optional_field_2

    assert_equal 40, @part2.cost_per_unit
    assert_equal "new description", @part2.description
    assert_equal "new notes", @part2.notes
    assert_equal "888777", @part2.optional_field_1
    assert_equal "777888", @part2.optional_field_2

    new_part = Part.last
    assert_equal "456def", new_part.mfg_part_number
    assert_equal "abc123", OtherPartNumber.where(company_type: "Customer").last.part_number
    assert_equal 3.5, new_part.cost_per_unit
    assert_equal "Warning Label (optional)\nacme #wl55", new_part.description
    assert_equal "notes", new_part.notes
    assert_equal 12, new_part.in_stock
    assert_equal "222111", new_part.optional_field_1
    assert_equal "111222", new_part.optional_field_2
    assert_equal 2, new_part.other_part_numbers.count
  end

  test "should import from partr csv" do
    assert_difference("OtherPartNumber.where(company_type: 'Manufacturer').count", 34) do
      assert_difference("Part.count", 34) do
        output = Part.csv_import("test/fixtures/files/parts_2024-05-23.csv", "Partr", @team)
        assert_equal "Parts Read: 34 | Parts Added: 34 | Manufacturers Added: 13", output
      end
    end
  end
end
