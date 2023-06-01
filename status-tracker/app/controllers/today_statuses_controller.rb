class TodayStatusesController < ApplicationController
  def index
    @statuses = Status.where(created_at: Time.zone.now.all_day, active: true)
  end
end
