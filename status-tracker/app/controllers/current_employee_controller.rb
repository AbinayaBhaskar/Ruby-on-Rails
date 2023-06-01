class CurrentEmployeeController < ApplicationController
  def show
    @employee = current_employee
  end
end
