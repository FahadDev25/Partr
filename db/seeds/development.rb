# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require "bcrypt"
require "faker"

us_states = [ "AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO",
              "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV",
              "WY" ]

random = Random.new
random.seed

org = Organization.create_with(
  phone_number: random.rand(9999999999).to_s.rjust(10, "0")
).find_or_create_by!(
  name: "Test Organization",
  abbr_name: "TOrg"
)
org.logo.attach(io: File.open("msi_header_logo_big.png"), filename: "msi_header_logo_big.png", content_type: "image/png") if !org.logo.attached?
org.update!(
  hq_address_attributes: {
    address_1: Faker::Address.street_address,
    address_2: Faker::Address.secondary_address,
    city: Faker::Address.city,
    state: us_states[random.rand(49)],
    zip_code: Faker::Address.zip_code,
    organization_id: org.id
  }
)

ActsAsTenant.current_tenant = org

default_role = TeamRole.find_or_create_by(role_name: "Default", create_destroy_job: true, all_job: false, all_order: false, all_shipment: false, organization_id: org.id)
admin_role = TeamRole.find_or_create_by(role_name: "Admin", create_destroy_job: true, all_job: true, all_order: true, all_shipment: true, organization_id: org.id)

team = Team.create_with(
  address_id: org.address_id,
  use_org_addr: true,
  use_org_phone: true,
  team_role_id: default_role.id,
  enable_manual_line_items: true
).find_or_create_by(
  name: "Test Team",
  organization_id: org.id
)

Team.create_with(
  address_id: org.address_id,
  use_org_addr: true,
  use_org_phone: true,
  team_role_id: admin_role.id,
).find_or_create_by(
  name: "Admin Team",
  organization_id: org.id
)

if User.count.zero?
  User.create!({ username: "admin", password: "password", password_confirmation: "password", first_name: "admin", last_name: "admin", email: "admin@bio-next.net",
                  organization_id: org.id, team_id: team.id })
end

if !org.user_id
  org.user_id = User.first.id
  org.save!
end

while User.count < 21
  name = Faker::FunnyName.unique.two_word_name.split(" ")
  user = User.create!(
    username: name[0][0] + name[1],
    password: "password",
    # encrypted_password: BCrypt::Password.create("password"),
    email: "#{Faker::Emotion.adjective + Faker::Creature::Animal.name.tr(" ", "")}@msi-group.com",
    first_name: name[0],
    last_name: name[1],
    force_2fa: false,
    organization_id: org.id,
    team_id: team.id
  )
  Employee.create!(
    user_id: user.id,
    organization_id: org.id,
    is_admin: false
  )
  TeamMember.create!(
    user_id: user.id,
    team_id: team.id,
    organization_id: org.id
  )
end

while Team.count < 21
  new_team = Team.create!(
    name: Faker::Job.unique.field,
    team_address_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    },
    phone_number: random.rand(9999999999).to_s.rjust(10, "0"),
    default_unit: Faker::Appliance.equipment,
    assembly_label: Faker::ElectricalComponents.electromechanical,
    organization_id: org.id,
    team_role_id: default_role.id
  )
  (random.rand(5) + 1).times do
    TeamMember.create!(
      team_id: new_team.id,
      user_id: User.all.sample.id,
      organization_id: org.id
    )
  end
end

User.all.each do |u|
  Employee.create_with(organization_id: org.id, is_admin: u.id == org.user_id).find_or_create_by(user_id: u.id)
  TeamMember.create_with(team_id: team.id, organization_id: org.id).find_or_create_by(user_id: u.id)
end

Vendor.find_or_create_by({ name: "American Electric", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Bussman", vendor_id: Vendor.find_by({ name: "American Electric" }).id, organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Hoffman", vendor_id: Vendor.find_by({ name: "American Electric" }).id, organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Eaton", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "BELIMO", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "DWYER", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "ENTRELEC", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Weidmuller", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "AB", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Allen-Bradley", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "ABB", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Hammond", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "PATLITE", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "MURR ELEKTRONIK", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "AUTOMATIONDIRECT", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Panduit", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Cutler-Hammer", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Thomas & Betts", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Phoenix Contact", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Graceport", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Festo", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "A2Z Cables", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "ASCO Numatics", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "CORTEC Corp", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "WATLOW", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "IONPURE", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "SANDISK", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Brady", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Rockwell", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Belden", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Ed Smith", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Grainger", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Mettler Toledo", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "ENM", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "P-TECH", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Ashcroft", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Fisher", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Emerson", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "McMaster-Carr", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Apollo", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Parker Paraflex", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "PISCO", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Square D", organization_id: org.id, team_id: team.id })
Manufacturer.find_or_create_by({ name: "Schneider Electric", organization_id: org.id, team_id: team.id })
Customer.find_or_create_by({ name: "MECO", organization_id: org.id, team_id: team.id })
parts = []
10.times do |i|
  part = Part.create_with(
    org_part_number: (1000000000 + i).to_s,
    description: "Part, Test #{i}",
    cost_per_unit: 0.5 * i,
    unit: "unit",
    optional_field_1: i.to_s,
    optional_field_2: i.to_s,
    in_stock: i * 10,
    notes: "test").find_or_create_by(
      mfg_part_number: "Test#{i}",
      manufacturer_id: (i % 2) + 1,
      organization_id: org.id,
      team_id: team.id)
  parts << part

  Team.all.pluck(:id).sample(random.rand(5) + 1).each do |team_id|
    SharedRecord.create!(
      shareable_type: "Part",
      shareable_id: part.id,
      team_id:,
      organization_id: org.id
    )
  end
end

assembly = Assembly.find_or_create_by(name: "Test Assembly", organization_id: org.id, team_id: team.id)
subassembly = Assembly.find_or_create_by(name: "Test Subassembly", organization_id: org.id, team_id: team.id)

Subassembly.find_or_create_by(parent_assembly_id: assembly.id, child_assembly_id: subassembly.id, quantity: 1, organization_id: org.id, team_id: team.id)

parts.each_with_index do |p, i|
  if [0, 1].include?(i % 3)
    Component.find_or_create_by(part_id: p.id, assembly_id: assembly.id, quantity: (i % 5) + 1, organization_id: org.id)
  else
    Component.find_or_create_by(part_id: p.id, assembly_id: subassembly.id, quantity: (i % 5) + 1, organization_id: org.id)
  end
end

job = Job.create_with(
  job_number: "TJ123",
  status: "Open",
  start_date: Date.today,
  deadline: Date.today + 30,
  customer_id: Customer.first.id,
  organization_id: org.id,
  team_id: team.id,
  project_manager_id: team.team_members.sample.user_id).find_or_create_by(name: "Test Job")

Unit.find_or_create_by(job_id: job.id, assembly_id: assembly.id, quantity: 1, organization_id: org.id)

parts.each_with_index do |p, i|
  AdditionalPart.find_or_create_by(part_id: p.id, job_id: job.id, quantity: (i % 5) + 1, organization_id: org.id)
end

job.update_cost

order = Order.create_with(
  order_date: Date.today,
  notes: "test", tax_rate: 0.05,
  freight_cost: 3.50,
  quantity_received: 0,
  received: false).find_or_create_by(job_id: job.id, vendor_id: Vendor.first.id, po_number: "adao23001", user_id: User.first.id, organization_id: org.id, team_id: team.id)

if order.line_items.length == 0
  order.add_all_parts_from_vendor
end
order.update_cost

shipment = Shipment.create_with(date_received: Date.today, notes: "test", organization_id: org.id, team_id: team.id).find_or_create_by(from: "MECO", shipping_number: "123456", job_id: job.id, order_id: order.id)

order.line_items.each do |li|
  PartReceived.find_or_create_by(
    shipment_id: shipment.id,
    part_id: li.part_id,
    assembly_id: li.assembly_id,
    id_sequence: li.id_sequence,
    job_id: job.id,
    quantity: li.quantity,
    organization_id: org.id
  )
end

if Part.count < 257
  puts "Starting part import..."
  puts Part.csv_import("db/seeds/appsheet_parts.csv", "Appsheet", team)
end

Part.all.each do |part|
  next unless part.manufacturer_id && part.primary_part_number == nil
  OtherPartNumber.create!(
    part_id: part.id,
    company_type: "Manufacturer",
    company_id: part.manufacturer_id,
    company_name: part.manufacturer.name,
    part_number: part.mfg_part_number,
    cost_per_unit: part.cost_per_unit,
    primary: true,
    organization_id: part.organization_id)
end

OtherPartNumber.all.each do |opn|
  next unless opn.cost_per_unit && opn.cost_per_unit > 0
  10.times do |i|
    cost_per_unit = opn.cost_per_unit * random.rand(0.0..2.0)
    PriceChange.create_with(cost_per_unit:, organization_id: org.id).find_or_create_by!(other_part_number_id: opn.id, date_changed: Date.today - i)
  end
end

while Assembly.count < 21
  new_assembly = Assembly.create!(
    name: Faker::Appliance.unique.equipment,
    notes: Faker::Lorem.paragraph,
    organization_id: org.id,
    team_id: team.id
  )
  new_assembly.update_totals
  (random.rand(5) + 1).times do
    new_assembly.add_part(Part.order("RANDOM()").limit(1)[0], random.rand(4) + 1, org).save!
  end
end

while Vendor.count < 21
  new_vendor = Vendor.create!(
    name: Faker::Company.unique.name,
    vendor_address_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    },
    phone_number: random.rand(9999999999).to_s.rjust(10, "0"),
    representative: Faker::Name.name,
    team_id: team.id,
    organization_id: org.id
  )
  if Vendor.count % 4 == 0
    new_vendor.vendor_address.address_2 = Faker::Address.secondary_address
    new_vendor.vendor_address.save!
  end
end

Manufacturer.where(vendor_id: nil).each do |manufacturer|
  manufacturer.vendor_id = Vendor.order("RANDOM()").limit(1)[0].id
  manufacturer.save!
end

Part.where(manufacturer_id: nil).each do |part|
  part.manufacturer_id = Manufacturer.order("RANDOM()").limit(1)[0].id
  part.mfg_part_number = Faker::Alphanumeric.alphanumeric(number: 10).upcase
  part.save!
end

while Customer.count < 21
  Customer.create!(
    name: Faker::TvShows::Seinfeld.unique.business,
    customer_address_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    },
    phone_number: random.rand(9999999999).to_s.rjust(10, "0"),
    team_id: team.id,
    organization_id: org.id
  )
end

while Job.count < 21
  new_job = Job.create!(
    job_number: Faker::Alphanumeric.alphanumeric(number: 10).upcase,
    name: Faker::Games::DnD.unique.monster,
    status: ["Pending", "Open", "Closed"][random.rand(3)],
    start_date: Date.today - random.rand(60),
    deadline: Date.today + random.rand(60),
    customer_id: Customer.order("RANDOM()").limit(1)[0].id,
    total_cost: 0,
    team_id: team.id,
    organization_id: org.id,
    jobsite_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    },
    project_manager_id: team.team_members.sample.user_id
  )
  (random.rand(5) + 1).times do
    new_job.add_assembly(Assembly.order("RANDOM()").limit(1)[0], random.rand(4) + 1, org)
  end
  (random.rand(5) + 1).times do
    new_job.add_part(Part.order("RANDOM()").limit(1)[0], random.rand(4) + 1)
  end
end

while Order.count < 21
  jobs_with_vendors = []
  Job.all.each { |job| jobs_with_vendors.push job if job.vendor_list.length > 0 }
  random_job = jobs_with_vendors.sample
  job_vendor_order = Order.create!(
    po_number: Order.next_po_number("ADAO"),
    job_id: random_job.id,
    vendor_id: random_job.vendor_list.sample.values[0],
    order_date: Date.today - random.rand(60),
    freight_cost: random.rand(249.99),
    tax_rate: random.rand(0.1),
    notes: Faker::Lorem.paragraph,
    user_id: User.first.id,
    organization_id: org.id,
    team_id: team.id,
    payment_method: ["VISA 123", "Cash", "Reimburse", "net 30", "Paypal"].sample,
    quantity_received: 0,
    received: false,
    ship_to_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    }
  )
  job_vendor_order.add_all_parts_from_vendor
  job_vendor_order.update_cost
  job_vendor_order.line_items.each_with_index do |li, i|
    li.update(
      expected_delivery: job_vendor_order.order_date + random.rand(14),
      om_warranty: ["no warranty", "warranty"].sample,
      status_location: Faker::TvShows::HeyArnold.location,
      notes: Faker::TvShows::HeyArnold.quote) if i % 2 == 0
  end

  vendors_with_parts = Vendor.joins(manufacturers: :parts)
  vendor_order = Order.create!(
    po_number: Order.next_po_number("ADAO"),
    vendor_id: vendors_with_parts.sample.id,
    order_date: Date.today - random.rand(60),
    freight_cost: random.rand(249.99),
    tax_rate: random.rand(0.1),
    notes: Faker::Lorem.paragraph,
    user_id: User.first.id,
    organization_id: org.id,
    team_id: team.id,
    payment_method: ["VISA 123", "Cash", "Reimburse", "net 30", "Paypal"].sample,
    quantity_received: 0,
    received: false,
    ship_to_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    }
  )
  vendor_parts = Part.joins(:manufacturer).where("manufacturers.vendor_id" => vendor_order.vendor_id)
  (random.rand(5) + 1).times do
    part = vendor_parts.order("RANDOM()").limit(1)[0]
    assembly = part.assemblies.sample || nil
    vendor_order.add_part(part, assembly, [], random.rand(10) + 1, random.rand(), org).save!
  end
  vendor_order.update_cost
  vendor_order.line_items.each_with_index do |li, i|
    li.update(
      expected_delivery: vendor_order.order_date + random.rand(14),
      om_warranty: ["no warranty", "warranty"].sample,
      status_location: Faker::TvShows::HeyArnold.location,
      notes: Faker::TvShows::HeyArnold.quote) if i % 2 == 0
  end

  new_order = Order.create!(
    po_number: Order.next_po_number("ADAO"),
    order_date: Date.today - random.rand(60),
    freight_cost: random.rand(99.99),
    notes: Faker::Lorem.paragraph,
    user_id: User.first.id,
    organization_id: org.id,
    team_id: team.id,
    payment_method: ["VISA 123", "Cash", "Reimburse", "net 30", "Paypal"].sample,
    quantity_received: 0,
    received: false,
    ship_to_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    }
  )
  if Order.count % 4 == 0
    new_order.parts_cost = random.rand(499.99)
    new_order.tax_total = random.rand(49.99)
    new_order.save!
  else
    new_order.tax_rate = random.rand(0.1)
    new_order.save!
    (random.rand(5) + 1).times do
      part = Part.order("RANDOM()").limit(1)[0]
      assembly = part.assemblies.sample || nil
      new_order.add_part(part, assembly, [], random.rand(10) + 1, random.rand(), org).save!
    end
    new_order.update_cost
  end
  new_order.line_items.each_with_index do |li, i|
    li.update(
      expected_delivery: new_order.order_date + random.rand(14),
      om_warranty: ["no warranty", "warranty"].sample,
      status_location: Faker::TvShows::HeyArnold.location,
      notes: Faker::TvShows::HeyArnold.quote) if i % 2 == 0
  end

  manual_order = Order.create!(
    po_number: Order.next_po_number("MANUAL"),
    order_date: Date.today - random.rand(60),
    freight_cost: random.rand(99.99),
    notes: Faker::Lorem.paragraph,
    user_id: User.first.id,
    organization_id: org.id,
    team_id: team.id,
    payment_method: ["VISA 123", "Cash", "Reimburse", "net 30", "Paypal"].sample,
    job_id: Job.all.sample.id,
    vendor_id: Vendor.all.sample.id,
    include_in_bom: true,
    quantity_received: 0,
    received: false,
    ship_to_attributes: {
      address_1: Faker::Address.street_address,
      address_2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: us_states[random.rand(49)],
      zip_code: Faker::Address.zip_code,
      organization_id: org.id
    }
  )
  (random.rand(5) + 1).times do
    LineItem.create!(
      order_id: manual_order.id,
      manual: true,
      cost_per_unit: random.rand(100.00),
      quantity: random.rand(10) + 1,
      description: Faker::Lorem.sentence,
      sku: Faker::Alphanumeric.alphanumeric(number: 10).upcase,
      expected_delivery: new_order.order_date + random.rand(14),
      om_warranty: ["no warranty", "warranty"].sample,
      status_location: Faker::TvShows::HeyArnold.location,
      notes: Faker::TvShows::HeyArnold.quote,
      discount: 0.0
    )
  end
  manual_order.update_cost
end

while Shipment.count < 21
  new_shipment = Shipment.create!(
    from: Customer.order("RANDOM()").limit(1)[0].name,
    shipping_number: random.rand(1000000).to_s.rjust(6, "0"),
    date_received: Date.today - random.rand(60),
    notes: Faker::Lorem.paragraph,
    organization_id: org.id,
    team_id: team.id
  )
  (random.rand(5) + 1).times do
    PartReceived.create!(
      shipment_id: new_shipment.id,
      part_id: Part.order("RANDOM()").limit(1)[0].id,
      quantity: random.rand(10) + 1,
      organization_id: org.id
    )
  end
  order = Order.where(job_id: nil).order("RANDOM()").limit(1)[0]
  order_shipment = Shipment.create!(
    order_id: order.id,
    from: order&.vendor&.name || "UPS",
    shipping_number: random.rand(1000000).to_s.rjust(6, "0"),
    date_received: Date.today - random.rand(60),
    notes: Faker::Lorem.paragraph,
    organization_id: org.id,
    team_id: team.id
  )
  if order.line_items.any?
    (random.rand(5) + 1).times do
      line_item = order.line_items.sample
      PartReceived.create!(
        shipment_id: order_shipment.id,
        part_id: line_item.part_id,
        quantity: random.rand(line_item.quantity) + 1,
        organization_id: org.id
      )
    end
  end
  jobs = Job.where.missing(:orders)
  jobs_with_vendors = []
  jobs.each { |j| jobs_with_vendors.push j if j.vendor_list.any? }
  job = jobs_with_vendors.sample
  job_shipment = Shipment.create!(
    job_id: job.id,
    from: job.customer.name,
    shipping_number: random.rand(1000000).to_s.rjust(6, "0"),
    date_received: Date.today - random.rand(60),
    notes: Faker::Lorem.paragraph,
    organization_id: org.id,
    team_id: team.id
  )
  parts = job.parts_list
  (random.rand(5) + 1).times do
    part_received = PartReceived.create!(
      shipment_id: job_shipment.id,
      job_id: job.id,
      part_id: parts.sample.values[0],
      quantity: random.rand(10) + 1,
      organization_id: org.id
    )
    if assembly = job.assembly_list(part_received.part).values.sample
      part_received.assembly_id = assembly[:id]
      part_received.id_sequence = assembly[:sequence]
      part_received.save!
    end
  end
  job_with_order = Job.joins(:orders).order("RANDOM()").limit(1)[0]
  order_with_job = job_with_order.orders.sample
  job_order_shipment = Shipment.create!(
    job_id: job_with_order.id,
    order_id: order_with_job.id,
    from: order_with_job&.vendor&.name || job.customer.name,
    shipping_number: random.rand(1000000).to_s.rjust(6, "0"),
    date_received: Date.today - random.rand(60),
    notes: Faker::ChuckNorris.fact,
    organization_id: org.id,
    team_id: team.id
  )
  if order_with_job.line_items.any?
    (random.rand(5) + 1).times do
      line_item = order_with_job.line_items.sample
      if line_item.manual
        part_received = PartReceived.create!(
          shipment_id: job_order_shipment.id,
          job_id: job_with_order.id,
          description: line_item.description,
          quantity: random.rand(line_item.quantity) + 1,
          organization_id: org.id
        )
      else
        part_received = PartReceived.create!(
          shipment_id: job_order_shipment.id,
          job_id: job_with_order.id,
          part_id: line_item.part_id,
          assembly_id: line_item.assembly_id,
          id_sequence: line_item.id_sequence,
          quantity: random.rand(line_item.quantity) + 1,
          organization_id: org.id
        )
      end
      if assembly = job_with_order.assembly_list(part_received.part).values.sample
        part_received.assembly_id = assembly[:id]
        part_received.id_sequence = assembly[:sequence]
        part_received.save!
      end
    end
  end
  Team.all.pluck(:id).sample(random.rand(5) + 1).each do |team_id|
    SharedRecord.create!(
      shareable_type: "Shipment",
      shareable_id: job_order_shipment.id,
      team_id:,
      organization_id: org.id
    )
    SharedRecord.create!(
      shareable_type: "Job",
      shareable_id: job_order_shipment.job_id,
      team_id:,
      organization_id: org.id
    )
    SharedRecord.create!(
      shareable_type: "Order",
      shareable_id: job_order_shipment.order_id,
      team_id:,
      organization_id: org.id
    )
  end
end
