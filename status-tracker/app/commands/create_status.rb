class CreateStatus
  PLAN = "plan".freeze
  ACTUAL = "actual".freeze
  class Error < StandardError; end
  class StatusExistsError < Error; end
  class MissingPlanError < Error; end

  def initialize(employee_id:, content:, status_type:, plan_id:)
    @employee_id = employee_id
    @content = content
    @status_type = status_type
    @plan_id = plan_id
  end

  def call
    raise StatusExistsError, "Status already exists" if status_exists?
    raise MissingPlanError, "Cannot be created without a plan" if missing_plan?

    create_status
  end

  private

  attr_reader :employee_id, :plan_id, :content, :status_type

  def create_status
    Status.create!(content:, status_type:, plan_id:, employee_id:)
  end

  def status_exists?
    Status.exists?(employee_id:, active: true, status_type:, created_at: Time.zone.today.all_day)
  end

  def missing_plan?
    !Status.exists?(id: plan_id, status_type: PLAN, active: true) if status_type == ACTUAL
  end
end
