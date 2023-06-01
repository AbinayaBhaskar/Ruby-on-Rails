class UpdateStatus
  ACTUAL = "actual".freeze
  class Error < StandardError; end
  class StatusNotFoundError < Error; end
  class ActualExistsError < Error; end
  class InactiveStatusError < Error; end

  delegate :employee_id, :plan_id, :status_type, to: :@previous_status

  def initialize(status_id:, content:)
    @status_id = status_id
    @content = content
  end

  def call
    raise StatusNotFoundError, "Status Not Found" if previous_status.blank?
    raise ActualExistsError, "Actual already defined cannot update the plan" if actual_defined?
    raise InactiveStatusError, "Cannot update an inactive status" unless previous_status.active

    update_status
  end

  private

  attr_reader :content, :status_id

  def previous_status
    @previous_status ||= Status.find_by(id: status_id)
  end

  def update_status
    ActiveRecord::Base.transaction do
      previous_status.update!(active: false)
      Status.create!(employee_id:, status_type:, content:, plan_id:)
    end
  end

  def actual_defined?
    Status.exists?(status_type: ACTUAL, active: true, plan_id: previous_status.id)
  end
end
