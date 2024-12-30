# frozen_string_literal: true

module ApplicationHelper
  def manufacturer_select_list(object, nil_name)
    select_list = if object.manufacturer
      Hash[object.manufacturer.name,
           object.manufacturer.id].merge!({ nil_name => nil })
    else
      { nil_name => nil }
    end
    select_list.merge!((Hash[Manufacturer.all.map { |m| [m.name, m.id] }]).sort_by { |k, _v| k }.to_h)
    select_list
  end

  def part_select_list(object)
    select_list = if object.part
      Hash[object.part.label,
           object.part.id].merge!({ "none" => nil })
    else
      { "none" => nil }
    end
    select_list.merge!(
      if object.instance_of?(::LineItem) && object.order
        if object.order.job
          (Hash[object.order.job.parts_list(object.order.vendor)]).sort_by { |k, _v| k }.to_h
        else
          (Hash[Part.where(id: current_user.current_team.parts.pluck(:id)).map { |pt| [pt.label, pt.id] }]).sort_by { |k, _v| k }.to_
        end
      else
        (Hash[Part.where(id: current_user.current_team.parts.pluck(:id)).map { |pt| [pt.label, pt.id] }]).sort_by { |k, _v| k }.to_h
      end
    )
    select_list
  end

  def subassembly_select_list(object, type)
    if type == "parent"
      select_list = object.parent_assembly ? Hash[object.parent_assembly.name, object.parent_assembly.id] : {}
    elsif type == "child"
      select_list = object.child_assembly ? Hash[object.child_assembly.name, object.child_assembly.id] : {}
    else
    end
    select_list.merge!((Hash[current_user.current_team.assemblies.map { |pl| [pl.name, pl.id] }]).sort_by { |k, _v| k }.to_h)
    select_list
  end

  def assembly_select_list(object)
    list = { "none" => nil }
    list.merge!(current_user.current_team.assemblies.order(:name).pluck(:name, :id).to_h)
  end

  def vendor_select_list(object, nil_name)
    select_list = if object.vendor
      Hash[object.vendor.name,
           object.vendor.id].merge!({ nil_name => nil })
    else
      { nil_name => nil }
    end
    select_list.merge!((Hash[Vendor.all.map { |v| [v.name, v.id] }]).sort_by { |k, _v| k }.to_h)
    select_list
  end

  def customer_select_list(object, nil_name)
    select_list = if object.customer
      Hash[object.customer.name,
           object.customer.id].merge!({ nil_name => nil })
    else
      { nil_name => nil }
    end
    select_list.merge!((Hash[Customer.all.map { |c| [c.name, c.id] }]).sort_by { |k, _v| k }.to_h)
    select_list
  end

  def job_select_list(object, nil_name)
    team = object.class.name == "Team" ? object : object&.team
    list = { nil_name => nil }
    if object.class.name == "Order"
      list.merge!(team.jobs.where.not(status: "Closed").or(Job.where(id: object.job_id || params[:preset])).order("created_at desc").to_h { |job| ["#{job.job_number} #{job.name}", job.id] }) unless team.nil?
    else
      list.merge!(team.jobs.order("created_at desc").to_h { |job| ["#{job.job_number} #{job.name}", job.id] }) unless team.nil?
    end
    list
  end

  def order_select_list(object, nil_name)
    list = { nil_name => nil }
    list.merge!(current_user.current_team.orders.order(:po_number).to_h { |order| [order.name, order.id] })
  end

  def shipment_select_list(object, nil_name)
    list = { nil_name => nil }
    list.merge!(current_user.current_team.shipments.order(:shipping_number).to_h { |shipment| [shipment.label, shipment.id] })
  end

  def team_select_list(nil_name)
    list = { nil_name => nil }
    list.merge!(Team.all.order(:name).pluck(:name, :id).to_h)
  end

  def team_member_select_list(team, nil_name)
    list = { nil_name => nil }
    list.merge!(team.users.order(:username).pluck(:username, :id).to_h)
  end

  def user_select_list(object, nil_name)
    list = { nil_name => nil }
    list.merge!(User.all.order(:username).pluck(:username, :id).to_h)
  end

  def active_class(link_path)
    current_page?(link_path) ? "active" : ""
  end

  def nav_link(link_text, link_path, current_page)
    content_tag(:li, class: ("active" if link_text.downcase.tr(" ", "_") == current_page)) do
      link_to link_text, link_path
    end
  end

  def us_states
    [
      ["", nil],
      ["AK", "AK"],
      ["AL", "AL"],
      ["AR", "AR"],
      ["AZ", "AZ"],
      ["CA", "CA"],
      ["CO", "CO"],
      ["CT", "CT"],
      ["DC", "DC"],
      ["DE", "DE"],
      ["FL", "FL"],
      ["GA", "GA"],
      ["HI", "HI"],
      ["IA", "IA"],
      ["ID", "ID"],
      ["IL", "IL"],
      ["IN", "IN"],
      ["KS", "KS"],
      ["KY", "KY"],
      ["LA", "LA"],
      ["MA", "MA"],
      ["MD", "MD"],
      ["ME", "ME"],
      ["MI", "MI"],
      ["MN", "MN"],
      ["MO", "MO"],
      ["MS", "MS"],
      ["MT", "MT"],
      ["NC", "NC"],
      ["ND", "ND"],
      ["NE", "NE"],
      ["NH", "NH"],
      ["NJ", "NJ"],
      ["NM", "NM"],
      ["NV", "NV"],
      ["NY", "NY"],
      ["OH", "OH"],
      ["OK", "OK"],
      ["OR", "OR"],
      ["PA", "PA"],
      ["RI", "RI"],
      ["SC", "SC"],
      ["SD", "SD"],
      ["TN", "TN"],
      ["TX", "TX"],
      ["UT", "UT"],
      ["VA", "VA"],
      ["VT", "VT"],
      ["WA", "WA"],
      ["WI", "WI"],
      ["WV", "WV"],
      ["WY", "WY"]
    ]
  end

  def truncate(string, max)
    return "-" unless string.present?
    string.truncate(max)
  end

  def recent_orders
    current_user.current_team.orders.order("created_at desc").first(5)
  end

  def subassembly_name_sequence(subassembly)
    name = ""
    subassembly[:sequence].each do |sa|
      name += Assembly.find(sa).name + "> "
    end
    name += Assembly.find(subassembly[:id]).name
  end

  def plural_capital_assembly
    if current_user&.current_team&.assembly_label && current_user&.current_team&.assembly_label != ""
      pluralize(2, current_user.current_team.assembly_label.capitalize)[2..]
    else
      "Assemblies"
    end
  end

  def capital_assembly
    if current_user&.current_team&.assembly_label && current_user&.current_team&.assembly_label != ""
      (current_user&.current_team&.assembly_label).capitalize.singularize
    else
      "Assembly"
    end
  end

  def plural_assembly
    if current_user&.current_team&.assembly_label && current_user&.current_team&.assembly_label != ""
      pluralize(2, current_user.current_team.assembly_label)[2..]
    else
      "assemblies"
    end
  end

  def assembly_label
    if current_user&.current_team&.assembly_label && current_user&.current_team&.assembly_label != ""
      (current_user&.current_team&.assembly_label).downcase.singularize
    else
      "assembly"
    end
  end

  def filter_select_list(table_name)
    case table_name
    when "customer"
      customer_select_list(Job.new, "any")
    when "manufacturer"
      manufacturer_select_list(Part.new, "any")
    when "vendor"
      vendor_select_list(Manufacturer.new, "any")
    when "state"
      us_states.unshift(["any", nil])
    when "job"
      job_select_list(current_user.current_team, "any")
    when "user"
      user_select_list(Order.new, "any")
    when "order_id"
      order_select_list(Shipment.new, "any")
    when "project_manager"
      list = { "any" => "any" }
      if current_user.current_team.role.all_job
        list.merge!(User.all.joins(:jobs).order(:username).pluck(:username, :id).to_h)
      else
        list.merge!(User.where(id: current_user.current_team.team_members.pluck(:user_id)).joins(:jobs).order(:username).pluck(:username, :id).to_h)
      end
    when "created_by"
      list = { "any" => "any" }
      if current_user.current_team.role.all_order
        list.merge!(User.all.joins(:orders).order(:username).pluck(:username, :id).to_h)
      else
        list.merge!(User.where(id: current_user.current_team.orders.pluck(:user_id)).joins(:orders).order(:username).pluck(:username, :id).to_h)
      end
    when "status"
      ["any", "hide Closed", "Pending", "Open", "Closed"]
    end
  end

  def number_to_cost(number)
    if (number || 0) * 100 % 1 == 0
      number_to_currency(number, precision: 2)
    else
      number_to_currency(number, precision: 4, strip_insignificant_zeros: true)
    end
  end

  def number_to_percent(number)
    if (number || 0) * 100 % 1 == 0
      number_to_percentage(number, precision: 2)
    else
      number_to_percentage(number, precision: 4, strip_insignificant_zeros: true)
    end
  end

  def placeholder(attribute, text = "-")
    attribute.present? ? attribute.to_s : text
  end
end
