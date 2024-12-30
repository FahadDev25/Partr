# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :check_2fa_force

  layout "error"

  def show
    @exception = request.env["action_dispatch.exception"]
    @status_code = @exception.try(:status_code) ||
                   ActionDispatch::ExceptionWrapper.new(
                    request.env, @exception
                  ).status_code

    render view_for_code(@status_code), status: @status_code, formats: :html
  end

  def not_found
    render view_for_code(404)
  end

  def internal_server
    render view_for_code(500)
  end

  private
    def view_for_code(code)
      supported_error_codes.fetch(code, "404")
    end

    def supported_error_codes
      {
        404 => "404",
        500 => "default"
      }
    end
end
