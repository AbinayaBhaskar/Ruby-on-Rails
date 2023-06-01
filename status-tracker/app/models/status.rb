class Status < ApplicationRecord
  class PlanDoesNotExistsError < StandardError; end
  belongs_to :employee
  belongs_to :plan, class_name: "Status", optional: true
  has_one :actual, -> { where active: true }, class_name: "Status", foreign_key: "plan_id", inverse_of: :plan
  has_one :slack_message
  before_create do
    raise PlanDoesNotExistsError if status_type == "actual" && plan_id.nil?
  end

  def self.within_dates(employee_id, from_date, to_date)
    where(employee_id:, created_at: from_date..to_date, active: true, status_type: "actual")
  end
end
