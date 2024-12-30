# frozen_string_literal: true

Rails.application.routes.draw do
  resources :team_roles
  resources :addresses
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#home"

  resources :teams do
    member do
      get "home"
      get "auto_print_orders"
    end
    resources :team_members, shallow: true
    resources :jobs, shallow: true do
      member do
        get "part_select_list"
        get "assembly_select_list"
        post "pin"
        delete "unpin"
      end
    end
    resources :orders, shallow: true do
      member do
        get "po"
        get "assembly_select_list"
        get "part_select_list"
      end
    end
    resources :shipments, shallow: true do
      member do
        get "part_select_list"
        get "assembly_select_list"
      end
    end
  end
  resource :job do
    get "address_fields"
    get "next_job_number"
  end
  resource :team do
    get "change_team"
    get "address_fields"
    get "phone_field"
    get "optional_part_field_name_field"
    get "project_manager_select"
    get "job_select"
  end
  resource :order do
    get "itemized_fields"
    get "totals_fields"
    get "next_po"
    get "billing_fields"
  end

  resources :parts_received
  resources :line_items, except: %i[ index show ] do
    member do
      get "parts_received_list"
    end
  end
  resource :line_item, except: %i[ index show ] do
    get "part_fields"
    get "description_fields"
  end
  resources :units do
    member do
      get "pdf"
      get "pdf_export"
      get "parts_ordered_list"
      get "parts_received_list"
      get "subassembly_parts_ordered_list"
      get "subassembly_parts_received_list"
      patch "subassembly_fill_from_stock"
    end
  end
  resources :additional_parts do
    member do
      get "parts_ordered_list"
      get "parts_received_list"
    end
  end
  resources :employees
  resources :organizations, except: :index
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    invitations: "users/invitations",
    passwords: "users/passwords",
    unlocks: "users/unlocks"
  }
  resources :users do
    member do
      patch "unlock_account"
    end
  end
  resources :customers
  resource :customer do
    get "csv_export"
    get "csv_import_form"
    post "csv_import"
  end
  resources :assemblies do
    member do
      get "pdf"
    end
  end
  resources :subassemblies
  resource :subassembly do
    get "child_assembly_select_list"
  end
  resources :components
  resources :vendors
  resource :vendor do
    get "csv_export"
    get "csv_import_form"
    post "csv_import"
  end
  resources :manufacturers
  resource :manufacturer do
    get "csv_export"
    get "csv_import_form"
    post "csv_import"
  end
  resources :parts do
    member do
      get "stock_form"
      patch "modify_stock"
      get "quick_links"
    end
    resources :other_part_numbers, shallow: true
  end
  resource :other_part_number do
    get "company_select"
  end
  resource :part do
    get "qr_codes"
    get "qr_codes_pdf"
    get "csv_import_form"
    get "csv_export"
  end
  namespace :twofactor_authentication do
    get "enable"
    get "setup"
    patch "verify"
    get "disable"
    patch "validate_disable"
  end
  namespace :pages do
    get "toggle_filters"
    get "export_form"
    get "export"
    get "export_options"
    get "changelog"
    get "search_results"
    get "admin"
  end
  resources :comments, except: %i[ index show ] do
    member do
      get "cancel_edit"
    end
  end
  resources :attachments, except: %i[ index show edit ]

  # CSV
  # export
  get "/jobs/:id/csv_export", to: "jobs#csv_export", as: "job_csv_export"
  # import
  post "parts/csv_import", to: "parts#csv_import", as: "part_csv_import"

  # Dependent Dropdowns
  get :get_parts_for_assembly, to: "assemblies#get_part_select_list"
  get :get_vendors_for_job, to: "jobs#get_vendor_select_list"
  get :get_orders_for_job, to: "jobs#get_order_select_list"

  # fill from inventory
  get :unit_fill_from_stock, to: "units#fill_from_stock"
  get :additional_part_fill_from_stock, to: "additional_parts#fill_from_stock"

  # Delete shipment packing slips
  delete :delete_packing_slip, to: "shipments#delete_packing_slip"

  # Filter
  get "part/toggle_filters", to: "parts#toggle_filters", as: "part_toggle_filters"
  get "component/toggle_filters", to: "components#toggle_filters", as: "component_toggle_filters"

  # Respond to /up with 200 ok
  get "/up", to: proc { [200, {}, [""]] }

  # errors
  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_server"
end
