# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_17_134826) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_parts", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "part_id", null: false
    t.decimal "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "received", default: false
    t.bigint "organization_id", null: false
    t.index ["job_id"], name: "index_additional_parts_on_job_id"
    t.index ["organization_id"], name: "index_additional_parts_on_organization_id"
    t.index ["part_id"], name: "index_additional_parts_on_part_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_addresses_on_organization_id"
  end

  create_table "assemblies", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.text "notes"
    t.bigint "customer_id"
    t.decimal "total_cost", precision: 10, scale: 4
    t.integer "total_components"
    t.decimal "total_quantity"
    t.index ["customer_id"], name: "index_assemblies_on_customer_id"
    t.index ["organization_id"], name: "index_assemblies_on_organization_id"
    t.index ["team_id"], name: "index_assemblies_on_team_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "attachable_type", null: false
    t.bigint "attachable_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "printed", default: false
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"
    t.index ["organization_id"], name: "index_attachments_on_organization_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["organization_id"], name: "index_comments_on_organization_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "components", force: :cascade do |t|
    t.bigint "part_id", null: false
    t.bigint "assembly_id", null: false
    t.decimal "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.index ["assembly_id"], name: "index_components_on_assembly_id"
    t.index ["organization_id"], name: "index_components_on_organization_id"
    t.index ["part_id"], name: "index_components_on_part_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.string "phone_number"
    t.bigint "address_id"
    t.text "po_message"
    t.index ["address_id"], name: "index_customers_on_address_id"
    t.index ["organization_id"], name: "index_customers_on_organization_id"
    t.index ["team_id"], name: "index_customers_on_team_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin"
    t.index ["organization_id"], name: "index_employees_on_organization_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.date "start_date"
    t.date "deadline"
    t.decimal "total_cost", precision: 10, scale: 4
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.string "job_number"
    t.bigint "project_manager_id"
    t.bigint "address_id"
    t.boolean "use_cust_addr"
    t.decimal "default_tax_rate", precision: 5, scale: 4
    t.index ["address_id"], name: "index_jobs_on_address_id"
    t.index ["customer_id"], name: "index_jobs_on_customer_id"
    t.index ["organization_id"], name: "index_jobs_on_organization_id"
    t.index ["project_manager_id"], name: "index_jobs_on_project_manager_id"
    t.index ["team_id"], name: "index_jobs_on_team_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "part_id"
    t.decimal "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "discount", precision: 3, scale: 2
    t.bigint "organization_id", null: false
    t.bigint "assembly_id"
    t.integer "id_sequence", array: true
    t.decimal "cost_per_unit", precision: 10, scale: 4
    t.boolean "manual", default: false
    t.text "description"
    t.date "expected_delivery"
    t.text "status_location"
    t.text "om_warranty"
    t.text "notes"
    t.string "sku"
    t.decimal "quantity_received"
    t.boolean "received"
    t.date "last_received_date"
    t.index ["assembly_id"], name: "index_line_items_on_assembly_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["organization_id"], name: "index_line_items_on_organization_id"
    t.index ["part_id"], name: "index_line_items_on_part_id"
  end

  create_table "manufacturers", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.index ["organization_id"], name: "index_manufacturers_on_organization_id"
    t.index ["team_id"], name: "index_manufacturers_on_team_id"
    t.index ["vendor_id"], name: "index_manufacturers_on_vendor_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "parts_cost", precision: 10, scale: 4
    t.date "order_date"
    t.bigint "vendor_id"
    t.bigint "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "po_number"
    t.decimal "tax_rate", precision: 5, scale: 4
    t.decimal "freight_cost", precision: 10, scale: 4
    t.text "notes"
    t.bigint "user_id", null: false
    t.decimal "tax_total", precision: 10, scale: 4
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.decimal "total_cost", precision: 10, scale: 4
    t.date "date_paid"
    t.decimal "amount_paid", precision: 8, scale: 2
    t.string "payment_method"
    t.string "payment_confirmation"
    t.boolean "mark_line_items_received"
    t.boolean "include_in_bom"
    t.bigint "address_id"
    t.bigint "billing_address_id"
    t.string "quote_number"
    t.string "fob"
    t.boolean "use_ship_for_bill"
    t.boolean "needs_reimbursement", default: false
    t.decimal "quantity_received"
    t.decimal "total_quantity"
    t.boolean "received"
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["billing_address_id"], name: "index_orders_on_billing_address_id"
    t.index ["job_id"], name: "index_orders_on_job_id"
    t.index ["organization_id"], name: "index_orders_on_organization_id"
    t.index ["team_id"], name: "index_orders_on_team_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["vendor_id"], name: "index_orders_on_vendor_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "abbr_name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.boolean "force_2fa"
    t.string "mcmaster_certificate"
    t.string "mcmaster_username"
    t.string "mcmaster_password"
    t.bigint "address_id"
    t.bigint "billing_address_id"
    t.string "fax_number"
    t.string "job_number_prefix"
    t.integer "print_count", default: 0
    t.index ["address_id"], name: "index_organizations_on_address_id"
    t.index ["billing_address_id"], name: "index_organizations_on_billing_address_id"
    t.index ["user_id"], name: "index_organizations_on_user_id"
  end

  create_table "other_part_numbers", force: :cascade do |t|
    t.string "company_name"
    t.string "part_number"
    t.bigint "part_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_type"
    t.bigint "company_id"
    t.string "url"
    t.decimal "cost_per_unit", precision: 10, scale: 4
    t.date "last_price_update"
    t.boolean "primary", default: false
    t.index ["company_type", "company_id"], name: "index_other_part_numbers_on_company"
    t.index ["organization_id"], name: "index_other_part_numbers_on_organization_id"
    t.index ["part_id"], name: "index_other_part_numbers_on_part_id"
  end

  create_table "parts", force: :cascade do |t|
    t.text "mfg_part_number"
    t.text "description"
    t.decimal "cost_per_unit", precision: 10, scale: 4
    t.decimal "in_stock", default: "0.0"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "optional_field_1"
    t.text "optional_field_2"
    t.bigint "manufacturer_id"
    t.string "unit"
    t.string "org_part_number"
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.string "url"
    t.date "last_price_update"
    t.index ["manufacturer_id"], name: "index_parts_on_manufacturer_id"
    t.index ["organization_id"], name: "index_parts_on_organization_id"
    t.index ["team_id"], name: "index_parts_on_team_id"
  end

  create_table "parts_received", force: :cascade do |t|
    t.bigint "shipment_id"
    t.decimal "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "part_id"
    t.bigint "assembly_id"
    t.bigint "job_id"
    t.bigint "organization_id", null: false
    t.integer "id_sequence", array: true
    t.bigint "line_item_id"
    t.text "description"
    t.bigint "user_id"
    t.string "status"
    t.date "date_received"
    t.index ["assembly_id"], name: "index_parts_received_on_assembly_id"
    t.index ["job_id"], name: "index_parts_received_on_job_id"
    t.index ["line_item_id"], name: "index_parts_received_on_line_item_id"
    t.index ["organization_id"], name: "index_parts_received_on_organization_id"
    t.index ["part_id"], name: "index_parts_received_on_part_id"
    t.index ["shipment_id"], name: "index_parts_received_on_shipment_id"
    t.index ["user_id"], name: "index_parts_received_on_user_id"
  end

  create_table "pinned_jobs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_pinned_jobs_on_job_id"
    t.index ["organization_id"], name: "index_pinned_jobs_on_organization_id"
    t.index ["team_id"], name: "index_pinned_jobs_on_team_id"
    t.index ["user_id"], name: "index_pinned_jobs_on_user_id"
  end

  create_table "price_changes", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.date "date_changed"
    t.decimal "cost_per_unit", precision: 10, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "other_part_number_id", null: false
    t.index ["organization_id"], name: "index_price_changes_on_organization_id"
    t.index ["other_part_number_id"], name: "index_price_changes_on_other_part_number_id"
  end

  create_table "shared_records", force: :cascade do |t|
    t.string "shareable_type", null: false
    t.bigint "shareable_id", null: false
    t.bigint "team_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_shared_records_on_organization_id"
    t.index ["shareable_type", "shareable_id"], name: "index_shared_records_on_shareable"
    t.index ["team_id"], name: "index_shared_records_on_team_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.text "from"
    t.text "shipping_number"
    t.date "date_received"
    t.text "notes"
    t.bigint "job_id"
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.bigint "user_id"
    t.string "status"
    t.index ["job_id"], name: "index_shipments_on_job_id"
    t.index ["order_id"], name: "index_shipments_on_order_id"
    t.index ["organization_id"], name: "index_shipments_on_organization_id"
    t.index ["team_id"], name: "index_shipments_on_team_id"
    t.index ["user_id"], name: "index_shipments_on_user_id"
  end

  create_table "subassemblies", force: :cascade do |t|
    t.bigint "parent_assembly_id", null: false
    t.bigint "child_assembly_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.integer "quantity"
    t.index ["child_assembly_id"], name: "index_subassemblies_on_child_assembly_id"
    t.index ["organization_id"], name: "index_subassemblies_on_organization_id"
    t.index ["parent_assembly_id"], name: "index_subassemblies_on_parent_assembly_id"
    t.index ["team_id"], name: "index_subassemblies_on_team_id"
  end

  create_table "team_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_team_members_on_organization_id"
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "team_roles", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "role_name"
    t.boolean "create_destroy_job"
    t.boolean "all_job"
    t.boolean "all_order"
    t.boolean "all_shipment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_team_roles_on_organization_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "use_org_addr"
    t.boolean "use_org_phone"
    t.string "phone_number"
    t.string "default_unit"
    t.string "assembly_label"
    t.string "order_received_email_timer"
    t.boolean "show_optional_part_field_1"
    t.boolean "show_optional_part_field_2"
    t.string "optional_part_field_1_name"
    t.string "optional_part_field_2_name"
    t.decimal "default_tax_rate", precision: 5, scale: 4
    t.integer "stale"
    t.integer "warn"
    t.boolean "enable_manual_line_items", default: false
    t.bigint "address_id"
    t.bigint "billing_address_id"
    t.boolean "use_org_billing"
    t.bigint "team_role_id", null: false
    t.string "share_jobs_with"
    t.string "share_orders_with"
    t.string "share_shipments_with"
    t.string "share_parts_with"
    t.integer "send_accounting_notifications_to", array: true
    t.index ["address_id"], name: "index_teams_on_address_id"
    t.index ["billing_address_id"], name: "index_teams_on_billing_address_id"
    t.index ["organization_id"], name: "index_teams_on_organization_id"
    t.index ["team_role_id"], name: "index_teams_on_team_role_id"
  end

  create_table "units", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "assembly_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "received", default: false
    t.bigint "organization_id", null: false
    t.index ["assembly_id"], name: "index_units_on_assembly_id"
    t.index ["job_id"], name: "index_units_on_job_id"
    t.index ["organization_id"], name: "index_units_on_organization_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.text "first_name"
    t.text "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.bigint "organization_id", null: false
    t.bigint "team_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "otp_secret"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.boolean "force_2fa"
    t.string "otp_backup_codes", array: true
    t.string "po_prefix"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.text "representative"
    t.bigint "organization_id", null: false
    t.bigint "team_id", null: false
    t.text "website"
    t.boolean "universal"
    t.bigint "address_id"
    t.index ["address_id"], name: "index_vendors_on_address_id"
    t.index ["organization_id"], name: "index_vendors_on_organization_id"
    t.index ["team_id"], name: "index_vendors_on_team_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_parts", "jobs"
  add_foreign_key "additional_parts", "organizations"
  add_foreign_key "additional_parts", "parts"
  add_foreign_key "addresses", "organizations"
  add_foreign_key "assemblies", "customers"
  add_foreign_key "assemblies", "organizations"
  add_foreign_key "assemblies", "teams"
  add_foreign_key "attachments", "organizations"
  add_foreign_key "comments", "organizations"
  add_foreign_key "comments", "users"
  add_foreign_key "components", "assemblies"
  add_foreign_key "components", "organizations"
  add_foreign_key "components", "parts"
  add_foreign_key "customers", "addresses"
  add_foreign_key "customers", "organizations"
  add_foreign_key "customers", "teams"
  add_foreign_key "employees", "organizations"
  add_foreign_key "employees", "users"
  add_foreign_key "jobs", "addresses"
  add_foreign_key "jobs", "customers"
  add_foreign_key "jobs", "organizations"
  add_foreign_key "jobs", "teams"
  add_foreign_key "jobs", "users", column: "project_manager_id"
  add_foreign_key "line_items", "assemblies"
  add_foreign_key "line_items", "orders"
  add_foreign_key "line_items", "organizations"
  add_foreign_key "line_items", "parts"
  add_foreign_key "manufacturers", "organizations"
  add_foreign_key "manufacturers", "teams"
  add_foreign_key "manufacturers", "vendors"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "addresses", column: "billing_address_id"
  add_foreign_key "orders", "jobs"
  add_foreign_key "orders", "organizations"
  add_foreign_key "orders", "teams"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "vendors"
  add_foreign_key "organizations", "addresses"
  add_foreign_key "organizations", "addresses", column: "billing_address_id"
  add_foreign_key "organizations", "users"
  add_foreign_key "other_part_numbers", "organizations"
  add_foreign_key "other_part_numbers", "parts"
  add_foreign_key "parts", "manufacturers"
  add_foreign_key "parts", "organizations"
  add_foreign_key "parts", "teams"
  add_foreign_key "parts_received", "assemblies"
  add_foreign_key "parts_received", "jobs"
  add_foreign_key "parts_received", "line_items"
  add_foreign_key "parts_received", "organizations"
  add_foreign_key "parts_received", "parts"
  add_foreign_key "parts_received", "shipments"
  add_foreign_key "parts_received", "users"
  add_foreign_key "pinned_jobs", "jobs"
  add_foreign_key "pinned_jobs", "organizations"
  add_foreign_key "pinned_jobs", "teams"
  add_foreign_key "pinned_jobs", "users"
  add_foreign_key "price_changes", "organizations"
  add_foreign_key "price_changes", "other_part_numbers"
  add_foreign_key "shared_records", "organizations"
  add_foreign_key "shared_records", "teams"
  add_foreign_key "shipments", "jobs"
  add_foreign_key "shipments", "orders"
  add_foreign_key "shipments", "organizations"
  add_foreign_key "shipments", "teams"
  add_foreign_key "shipments", "users"
  add_foreign_key "subassemblies", "assemblies", column: "child_assembly_id"
  add_foreign_key "subassemblies", "assemblies", column: "parent_assembly_id"
  add_foreign_key "subassemblies", "organizations"
  add_foreign_key "subassemblies", "teams"
  add_foreign_key "team_members", "organizations"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "team_roles", "organizations"
  add_foreign_key "teams", "addresses"
  add_foreign_key "teams", "addresses", column: "billing_address_id"
  add_foreign_key "teams", "organizations"
  add_foreign_key "teams", "team_roles"
  add_foreign_key "units", "assemblies"
  add_foreign_key "units", "jobs"
  add_foreign_key "units", "organizations"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "teams"
  add_foreign_key "vendors", "addresses"
  add_foreign_key "vendors", "organizations"
  add_foreign_key "vendors", "teams"
end
