# frozen_string_literal: true

class PagesController < ApplicationController
  include Search

  skip_before_action :authenticate_user!, only: %i[ home ]
  skip_before_action :check_2fa_force, only: %i[ home ]
  before_action :set_object, only: %i[ export export_form ]

  def admin
    authorize
  end

  def export
    options = params.except(:commit, :controller, :action).to_unsafe_h
    case params[:file_type]
    when "PDF"
      file = @object.pdf(**options)
      extension = ".pdf"
    when "CSV"
      file = @object.csv(**options)
      extension = ".csv"
    else
    end

    respond_to do |format|
      format.html { send_data(file, filename: @object.filename + extension) }
    end
  end

  def export_form
  end

  def export_options
    preset_hash = JSON.parse params[:preset].gsub("=>", ":")
    format_options = []
    if params[:value] == "PDF"
      format_options = preset_hash["pdf_format_options"]
      boolean_options = preset_hash["pdf_boolean_options"]
    elsif params[:value] == "CSV"
      format_options = preset_hash["csv_format_options"]
      boolean_options = preset_hash["csv_boolean_options"]
    end

    respond_to do |format|
      format.html { render "pages/export_options", locals: { format_options:, boolean_options: } }
    end
  end

  def home
    if current_user.present?
      redirect_to home_team_path(current_user.current_team)
    else
      render layout: "layouts/home"
    end
  end

  def set_object
    case params[:class]
    when "Order"
      @object = Order.find(params[:id])
    when "Assembly"
      @object = Assembly.find(params[:id])
    when "Unit"
      @object = Unit.find(params[:id])
    else
    end
    @cost_optional = params[:cost_optional]
  end

  def search_results
    @jobs = job_search(params[:query])
    @jobs = @jobs.where(team_id: current_user.team_members.pluck("team_members.team_id")) unless current_user.is_admin
    @orders = order_search(params[:query])
    @orders = @orders.where(team_id: current_user.team_members.pluck("team_members.team_id")) unless current_user.is_admin
    @shipments = shipment_search(params[:query])
    @shipments = @shipments.where(team_id: current_user.team_members.pluck("team_members.team_id")) unless current_user.is_admin
  end

  def toggle_filters
    parent_params = params.except(:show_filters, :filters, :target, :action, :controller, :format).to_unsafe_h
    show_filters = params[:show_filters] == "true"
    filters = params[:filters].flatten.each_slice(3).to_a
    respond_to do |format|
      format.html { }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("search_and_filters", partial: "pages/search_filter",
                locals: { show_filters: !show_filters, parent_params:, target: params[:target], url: params[:url], filters: })
      end
    end
  end
end
