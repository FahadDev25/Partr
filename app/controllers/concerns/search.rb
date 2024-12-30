# frozen_string_literal: true

module Search
  # assemblies
  def assembly_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if k.to_s == "customer"
          key_string += k.to_s + "_id= ? AND "
          value_array.push(v)
        elsif ["total_cost", "total_components", "total_quantity"].include?(k.to_s)
          min, max = v.split("to")
          if ![min, max].intersect?(["", nil])
            key_string += k.to_s + " BETWEEN ? AND ? AND "
            value_array.push(min)
            value_array.push(max)
          elsif min != ""
            key_string += k.to_s + ">= ? AND "
            value_array.push(min)
          else
            key_string += k.to_s + "<= ? AND "
            value_array.push(max)
          end
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        assembly_search(filters[:query]).where(query_array)
      else
        Assembly.where(query_array)
      end
    elsif filters[:query]
      assembly_search(filters[:query])
    else
      Assembly.all
    end
  end

  def assembly_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Assembly.where("name ILIKE ?", "%" + query + "%").or(
        Assembly.where("notes ILIKE ?", "%" + query + "%").or(
          Assembly.where(customer_id: Customer.where("name ILIKE ?", "%" + query + "%").pluck(:id))
        )
      )
    else
      Assembly.all
    end
  end

  def assembly_sort(assemblies, order_by, order)
    allowed_order_by = ["name", "total_cost", "total_components", "total_quantity"]
    allowed_order = ["ASC", "DESC"]
    return assemblies unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    assemblies.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
  end

  # components
  def component_filter(filters)
    if filters.except(:query, :id) != {}
      key_string = ""
      value_array = []
      filters.except(:query, :id).each do |k, v|
        if k.to_s == "manufacturer"
          key_string += k.to_s + "_id= ? AND "
          value_array.push(v)
        elsif ["cost_per_unit", "in_stock"].include?(k.to_s)
          min, max = v.split("to")
          if ![min, max].intersect?(["", nil])
            key_string += k.to_s + " BETWEEN ? AND ? AND "
            value_array.push(min)
            value_array.push(max)
          elsif min != ""
            key_string += k.to_s + ">= ? AND "
            value_array.push(min)
          else
            key_string += k.to_s + "<= ? AND "
            value_array.push(max)
          end
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        component_search(filters[:query], filters[:id]).where(query_array)
      else
        Component.where(assembly_id: filters[:id]).left_outer_joins(:part).where(query_array)
      end
    elsif filters[:query]
      component_search(filters[:query], filters[:id])
    else
      Component.where(assembly_id: filters[:id]).left_outer_joins(:part).where(assembly_id: filters[:id])
    end
  end

  def component_sort(components, order_by, order)
    allowed_order_by = ["part", "parts.description", "parts.cost_per_unit", "quantity", "total_cost"]
    allowed_order = ["ASC", "DESC"]
    return components unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    order = order == "ASC" ? "ASC" : "DESC"
    if order_by == "part"
      components.left_outer_joins(part: :manufacturer).order(ActiveRecord::Base.sanitize_sql_for_order("manufacturers.name #{order}, parts.mfg_part_number #{order}"))
    elsif order_by == "total_cost"
      components.left_outer_joins(:part).order(ActiveRecord::Base.sanitize_sql_for_order(Arel.sql("(parts.cost_per_unit * quantity) #{order}")))
    else
      components.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end

  def component_search(query, id)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Component.where(assembly_id: id).left_outer_joins(:part).where("parts.mfg_part_number ILIKE ?", "%" + query + "%").or(
        Component.where(assembly_id: id).left_outer_joins(:part).where("parts.manufacturer_id": Manufacturer.where("name ILIKE ?", "%" + query + "%").pluck(:id)).or(
          Component.where(assembly_id: id).left_outer_joins(:part).where("description ILIKE ?", "%" + query + "%")
        )
      )
    else
      Component.where(assembly_id: filters[:id]).left_outer_joins(:part).all
    end
  end

  # customers
  def customer_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if k.to_s == "phone_number"
          key_string += "CAST(#{k} AS TEXT) LIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        elsif ["address", "city", "state", "zip_code"].include? k.to_s
          key_string = address_filter_string(k, v, key_string)
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        customer_search(filters[:query]).where(query_array)
      else
        Customer.where(query_array)
      end
    elsif filters[:query]
      customer_search(filters[:query])
    else
      Customer.all
    end
  end

  def customer_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Customer.where("name ILIKE ?", "%" + query + "%")
    else
      Customer.all
    end
  end

  def customer_sort(customers, order_by, order)
    allowed_order_by = ["name", "address_1", "city", "state", "zip_code", "phone_number", "representative"]
    allowed_order = ["ASC", "DESC"]
    return customers unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if ["address_1", "city", "state", "zip_code"].include? order_by
      customers.left_outer_joins(:customer_address).order(ActiveRecord::Base.sanitize_sql_for_order("addresses.#{order_by} #{order}"))
    else
      customers.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end

  # jobs
  def job_filter(filters)
    session[:project_manager] = filters[:project_manager] if filters[:project_manager].present?
    session[:status] = filters[:status] if filters[:status].present?
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        next unless v.present?
        if ["customer", "project_manager"].include? k.to_s
          next if v.to_i == 0
          key_string += k.to_s + "_id= ? AND "
          value_array.push(v)
        elsif k.to_s == "status" && (v == "hide Closed" || v == "any")
          key_string += "(NOT #{k} ILIKE 'Closed' OR #{k} is NULL) AND " if v == "hide Closed"
        elsif ["total_cost", "start_date", "deadline"].include?(k.to_s)
          min, max = v.split("to")
          if ![min, max].intersect?(["", nil])
            key_string += k.to_s + " BETWEEN ? AND ? AND "
            value_array.push(min)
            value_array.push(max)
          elsif min != ""
            key_string += k.to_s + ">= ? AND "
            value_array.push(min)
          else
            key_string += k.to_s + "<= ? AND "
            value_array.push(max)
          end
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        job_search(filters[:query]).where(query_array)
      else
        Job.where(query_array)
      end
    elsif filters[:query]
      job_search(filters[:query])
    else
      Job.all
    end
  end

  def job_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Job.where("name ILIKE ?", "%" + query + "%").or(
        Job.where(customer_id: Customer.where("name ILIKE ?", "%" + query + "%").pluck(:id)).or(
          Job.where("job_number ILIKE ?", "%" + query + "%")
        )
      )
    else
      Assembly.all
    end
  end

  def job_sort(jobs, order_by, order)
    allowed_order_by = ["job_number", "name", "status", "start_date", "deadline", "total_cost", "customer", "project_manager"]
    allowed_order = ["ASC", "DESC"]
    return jobs unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if order_by == "customer"
      jobs.left_outer_joins(:customer).order(ActiveRecord::Base.sanitize_sql_for_order("customers.name #{order}"))
    elsif order_by == "project_manager"
      jobs.left_outer_joins(:project_manager).order(ActiveRecord::Base.sanitize_sql_for_order("users.username #{order}"))
    else
      jobs.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end


  # manufacturers
  def manufacturer_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if k.to_s == "vendor"
          key_string += k.to_s + "_id= ? AND "
          value_array.push(v)
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        manufacturer_search(filters[:query]).where(query_array)
      else
        Manufacturer.where(query_array)
      end
    elsif filters[:query]
      manufacturer_search(filters[:query])
    else
      Manufacturer.all
    end
  end

  def manufacturer_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Manufacturer.where("name ILIKE ?", "%" + query + "%").or(
        Manufacturer.where(vendor_id: Vendor.where("name ILIKE ?", "%" + query + "%").pluck(:id))
      )
    else
      Manufacturer.all
    end
  end

  def manufacturer_sort(manufacturers, order_by, order)
    allowed_order_by = ["name", "vendor"]
    allowed_order = ["ASC", "DESC"]
    return manufacturers unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if order_by == "vendor"
      manufacturers.left_outer_joins(:vendor).order(ActiveRecord::Base.sanitize_sql_for_order("vendors.name #{order}"))
    else
      manufacturers.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end

  # orders
  def order_filter(filters)
    session[:created_by] = filters[:created_by] if filters[:created_by].present?
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        next unless v.present?
        if ["vendor", "job", "customer"].include?(k.to_s)
          key_string += k.to_s + "_id= ? AND "
          value_array.push(v)
        elsif ["created_by"].include?(k.to_s)
          if v != "any"
            key_string += "user_id= ? AND "
            value_array.push(v)
          end
        elsif ["order_date", "parts_cost", "tax_rate", "tax_total", "freight_cost", "total_cost"].include?(k.to_s)
          min, max = v.split("to")
          if ![min, max].intersect?(["", nil])
            key_string += k.to_s + " BETWEEN ? AND ? AND "
            value_array.push(min)
            value_array.push(max)
          elsif min != ""
            key_string += k.to_s + ">= ? AND "
            value_array.push(min)
          else
            key_string += k.to_s + "<= ? AND "
            value_array.push(max)
          end
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        order_search(filters[:query]).where(query_array)
      else
        Order.where(query_array)
      end
    elsif filters[:query]
      order_search(filters[:query])
    else
      Order.all
    end
  end

  def order_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Order.where("po_number ILIKE ?", "%" + query + "%").or(
        Order.where(job_id: Job.where("name ILIKE ? OR job_number ILIKE ?", "%" + query + "%", "%" + query + "%").pluck(:id)).or(
          Order.where(vendor_id: Vendor.where("name ILIKE ?", "%" + query + "%").pluck(:id))
        )
      )
    else
      Order.all
    end
  end

  def order_sort(orders, order_by, order)
    allowed_order_by = ["po_number", "job", "vendor", "order_date", "parts_cost", "tax_rate", "tax_total", "freight_cost", "total_cost", "user",
                        "date_paid", "amount_paid", "parts_received", "payment_method", "payment_confirmation", "created_at"]
    allowed_order = ["ASC", "DESC"]
    return orders unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if ["job", "vendor"].include? order_by
      orders.left_outer_joins(order_by.to_sym).order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by}s.name #{order}"))
    elsif ["user"].include? order_by
      orders.left_outer_joins(order_by.to_sym).order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by}s.username #{order}"))
    elsif order_by == "parts_received"
      order_ids = orders.left_outer_joins(shipments: :parts_received).group(:id).sum("parts_received.quantity")
        .sort_by { |_key, value| params[:order] == "ASC" ? value : -value }.to_h.keys
      Order.find(order_ids)
    else
      orders.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end

  # parts
  def part_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if k.to_s == "manufacturer"
          key_string += k.to_s + "_id= ? AND "
          value_array.push(v)
        elsif ["cost_per_unit", "in_stock"].include?(k.to_s)
          min, max = v.split("to")
          if ![min, max].intersect?(["", nil])
            key_string += k.to_s + " BETWEEN ? AND ? AND "
            value_array.push(min)
            value_array.push(max)
          elsif min != ""
            key_string += k.to_s + ">= ? AND "
            value_array.push(min)
          else
            key_string += k.to_s + "<= ? AND "
            value_array.push(max)
          end
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        part_search(filters[:query]).where(query_array)
      else
        Part.where(query_array)
      end
    elsif filters[:query]
      part_search(filters[:query])
    else
      Part.all
    end
  end

  def part_sort(parts, order_by, order)
    allowed_order_by = ["org_part_number", "mfg_part_number", "manufacturers.name", "description", "cost_per_unit", "in_stock", "notes",
                        "optional_field_1", "optional_field_2"]
    allowed_order = ["ASC", "DESC"]
    return parts unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if order_by == "manufacturers.name"
      parts.left_outer_joins(:manufacturer).order(ActiveRecord::Base.sanitize_sql_for_order("manufacturers.name #{order}"))
    else
      parts.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end

  def part_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Part.where("org_part_number ILIKE ?", "%" + query + "%").or(
        Part.where("mfg_part_number ILIKE ?", "%" + query + "%").or(
          Part.where(manufacturer_id: Manufacturer.where("name ILIKE ?", "%" + query + "%").pluck(:id)).or(
            Part.where("description ILIKE ?", "%" + query + "%").or(
              Part.where("notes ILIKE ?", "%" + query + "%")
            )
          )
        )
      )
    else
      Part.all
    end
  end

  # shipments
  def shipment_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if ["job"].include?(k.to_s)
          key_string += k.to_s + "_id= ? AND "
          value_array.push(v)
        elsif ["order_id"].include?(k.to_s)
          key_string += k.to_s + "= ? AND "
          value_array.push(v)
        elsif ["date_received"].include?(k.to_s)
          min, max = v.split("to")
          if ![min, max].intersect?(["", nil])
            key_string += k.to_s + " BETWEEN ? AND ? AND "
            value_array.push(min)
            value_array.push(max)
          elsif min != ""
            key_string += k.to_s + ">= ? AND "
            value_array.push(min)
          else
            key_string += k.to_s + "<= ? AND "
            value_array.push(max)
          end
        else
          key_string += "\"#{k}\" ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        shipment_search(filters[:query]).where(query_array)
      else
        Shipment.where(query_array)
      end
    elsif filters[:query]
      shipment_search(filters[:query])
    else
      Shipment.all
    end
  end

  def shipment_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Shipment.where(job_id: Job.where("name ILIKE ? OR job_number ILIKE ?", "%" + query + "%", "%" + query + "%").pluck(:id)).or(
        Shipment.where(order_id: Order.where(vendor_id: Vendor.where("name ILIKE ?", "%" + query + "%").pluck(:id))).or(
          Shipment.where("\"from\" ILIKE ?", "%" + query + "%").or(
            Shipment.where("shipping_number ILIKE ?", "%" + query + "%").or(
              Shipment.where("notes ILIKE ?", "%" + query + "%").or(
                Shipment.where(order_id: Order.where("po_number ILIKE ?", "%" + query + "%").pluck(:id))
              )
            )
          )
        )
      )
    else
      Shipment.all
    end
  end

  def shipment_sort(shipments, order_by, order)
    allowed_order_by = ["job", "order", "from", "shipping_number", "shipping_number", "date_received", "notes", "user"]
    allowed_order = ["ASC", "DESC"]
    return shipments unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    case order_by
    when "job"
      shipments.left_outer_joins(order_by.to_sym).order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by}s.name #{order}"))
    when "order"
      shipments.left_outer_joins(order_by.to_sym).order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by}s.po_number #{order}"))
    when "user"
      shipments.left_outer_joins(order_by.to_sym).order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by}s.username #{order}"))
    else
      shipments.order(ActiveRecord::Base.sanitize_sql_for_order("\"#{order_by}\" #{order}"))
    end
  end

  # teams
  def team_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if k.to_s == "phone_number"
          key_string += "CAST(#{k} AS TEXT) LIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        elsif ["address", "city", "state", "zip_code"].include? k.to_s
          key_string = address_filter_string(k, v, key_string)
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        team_search(filters[:query]).where(query_array)
      else
        Team.where(query_array)
      end
    elsif filters[:query]
      team_search(filters[:query])
    else
      Team.all
    end
  end

  def team_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Team.where("name ILIKE ?", "%" + query + "%")
    else
      Team.all
    end
  end

  def team_sort(teams, order_by, order)
    allowed_order_by = ["name", "address_1", "city", "state", "zip_code", "phone_number", "representative", "default_unit", "assembly_label"]
    allowed_order = ["ASC", "DESC"]
    return teams unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if ["address_1", "city", "state", "zip_code"].include? order_by
      teams.left_outer_joins(:team_address).order(ActiveRecord::Base.sanitize_sql_for_order("addresses.#{order_by} #{order}"))
    else
      teams.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end

  # users
  def user_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if ["is_admin"].include?(k.to_s)
          key_string += "employees.#{k}= ? AND "
          value_array.push("#{v == "true"}")
        else
          key_string += "\"#{k}\" ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        user_search(filters[:query]).joins(:employee).where(query_array)
      else
        User.joins(:employee).where(query_array)
      end
    elsif filters[:query]
      user_search(filters[:query])
    else
      User.all
    end
  end

  def user_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      User.where("username ILIKE ?", "%" + query + "%").or(
        User.where("first_name ILIKE ?", "%" + query + "%").or(
          User.where("last_name ILIKE ?", "%" + query + "%").or(
            User.where("email ILIKE ?", "%" + query + "%")
          )
        )
      )
    else
      User.all
    end
  end

  def user_sort(users, order_by, order)
    allowed_order_by = ["username", "first_name", "last_name", "email", "is_admin"]
    allowed_order = ["ASC", "DESC"]
    return users unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if ["is_admin"].include? order_by
      users.left_outer_joins(:employee).order(ActiveRecord::Base.sanitize_sql_for_order("employees.is_admin #{order}"))
    else
      users.order(ActiveRecord::Base.sanitize_sql_for_order("\"#{order_by}\" #{order}"))
    end
  end

  # vendors
  def vendor_filter(filters)
    if filters.except(:query) != {}
      key_string = ""
      value_array = []
      filters.except(:query).each do |k, v|
        if k.to_s == "phone_number"
          key_string += "CAST(#{k} AS TEXT) LIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        elsif ["address", "city", "state", "zip_code"].include? k.to_s
          key_string = address_filter_string(k, v, key_string)
        else
          key_string += k.to_s + " ILIKE ? AND "
          value_array.push("%#{ActiveRecord::Base.sanitize_sql_like(v)}%")
        end
      end
      query_array = ActiveRecord::Base.sanitize_sql_array([key_string[0..-6]] + value_array)
      if filters[:query]
        vendor_search(filters[:query]).where(query_array)
      else
        Vendor.where(query_array)
      end
    elsif filters[:query]
      vendor_search(filters[:query])
    else
      Vendor.all
    end
  end

  def vendor_search(query)
    if query != ""
      query = ActiveRecord::Base.sanitize_sql_like(query)
      Vendor.where("name ILIKE ?", "%" + query + "%").or(
        Vendor.where("representative ILIKE ?", "%" + query + "%")
      )
    else
      Vendor.all
    end
  end

  def vendor_sort(vendors, order_by, order)
    allowed_order_by = ["name", "address_1", "city", "state", "zip_code", "phone_number", "representative", "website"]
    allowed_order = ["ASC", "DESC"]
    return vendors unless allowed_order_by.include?(order_by) && allowed_order.include?(order)
    if ["address_1", "city", "state", "zip_code"].include? order_by
      vendors.left_outer_joins(:vendor_address).order(ActiveRecord::Base.sanitize_sql_for_order("addresses.#{order_by} #{order}"))
    else
      vendors.order(ActiveRecord::Base.sanitize_sql_for_order("#{order_by} #{order}"))
    end
  end

  # addresses
  def address_filter_string(key, value, key_string)
    case key
    when "address"
      addresses = Address.where("address_1 ILIKE ? OR address_2 ILIKE ?", "%#{value}%", "%#{value}%").pluck(:id)
    when "city"
      addresses = Address.where("city ILIKE ?", "%#{value}%").pluck(:id)
    when "state"
      addresses = Address.where("state ILIKE ?", "%#{value}%").pluck(:id)
    when "zip_code"
      addresses = Address.where("zip_code ILIKE ?", "%#{value}%").pluck(:id)
    end
    key_string += "address_id IN (#{addresses.any? ? addresses.join(",") : "NULL"}) AND "
    key_string
  end
end
