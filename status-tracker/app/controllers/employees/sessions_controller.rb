module Employees
  class SessionsController < Devise::SessionsController
    include RackSessionFix

    respond_to :json

    private

    def respond_with(_resource, _opts = {})
      render json: { message: "Logged in", data: current_employee }, status: :ok
    end

    def respond_to_on_destroy
      if current_employee
        render json: { message: "logged out successfully" }, status: :ok
      else
        render json: { message: "Couldn't find an active session." }, status: :unauthorized
      end
    end
  end
end
