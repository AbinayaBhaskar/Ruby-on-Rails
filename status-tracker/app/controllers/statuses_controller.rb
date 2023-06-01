class StatusesController < ApplicationController
  before_action :missing_content, only: %i[create update]
  # before_action :out_of_range, only: %i[index]

  def index
    # @statuses= Status.all
    @statuses = Status.within_dates(params[:employee_id], params[:from_date], params[:to_date])
  end

  def create
    @status = CreateStatus.new(employee_id: current_employee&.id, content: status_params[:content],
                               status_type: status_params[:status_type], plan_id: status_params[:plan_id]).call
  rescue CreateStatus::Error => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def update
    @status = UpdateStatus.new(status_id: params[:id], content: status_params[:content]).call
  rescue UpdateStatus::Error => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  private

  def status_params
    params.require(:status).permit(:content, :status_type, :plan_id).with_defaults(plan_id: nil)
  end

  def missing_content
    render json: { message: "Content is Missing" }, status: :unprocessable_entity if status_params[:content].blank?
  end

  def missing_dates
    missing_dates = params[:from_date].blank? && params[:to_date].blank?
    render json: { message: "Dates are not specified" }, status: :unprocessable_entity if missing_dates
  end

  def out_of_range
    invalid_dates = (Date.parse(params[:to_date]) - Date.parse(params[:from_date])).to_i >= 40
    render json: { message: "Range exceeded 40 days" }, status: :unprocessable_entity if invalid_dates
  end
end
