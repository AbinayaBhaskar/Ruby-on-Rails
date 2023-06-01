module Employees
  class RegistrationsController < Devise::RegistrationsController
    include RackSessionFix

    respond_to :json

    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: { message: 'Signed up', data: resource }, status: :ok
      else
        render json: { message: resource.inactive_message }, status: :unprocessable_entity
      end
    end
  end
end
