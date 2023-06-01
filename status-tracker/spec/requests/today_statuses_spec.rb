require 'rails_helper'

RSpec.describe 'TodayStatuses' do
  describe 'GET /today_statuses' do
    let(:employee) { create(:employee) }

    context 'when retrieving statuses' do
      let(:employee_list) { create_list(:employee, 5) }
      let!(:plans) { employee_list.map { |employee| create(:status, :plan, employee:) } }
      let!(:actuals) { plans.map { |plan| create(:status, :actual, plan:, employee: plan.employee) } }
      let(:today_status_response) do
        (plans + actuals).map do |status|
          {
            employee_name: status.employee.name,
            id: status.id,
            content: status.content,
            status_type: status.status_type,
            created_at: status.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
            updated_at: status.updated_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
            employee_id: status.employee_id,
            plan_id: status.plan_id
          }.stringify_keys
        end
      end

      before do
        past_plan = create(:status, :plan, employee:, created_at: 3.days.ago, updated_at: 3.days.ago)
        create(:status, :actual, plan_id: past_plan.id, employee:, created_at: 3.days.ago, updated_at: 3.days.ago)

        sign_in(employee)
        get '/today_statuses', as: :json
      end

      it 'returns a success status' do
        expect(response).to have_http_status(:success)
      end

      it 'returns today\'s statuses for all employees' do
        expect(JSON.parse(response.body)).to match(today_status_response)
      end
    end

    context 'when statuses have not been added' do
      before do
        sign_in(employee)
        get '/today_statuses', as: :json
      end

      it 'returns an empty array' do
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'when statuses are inactive' do
      before do
        sign_in(employee)
        create(:status, :plan, active: false)
      end

      it 'returns an empty array' do
        get '/today_statuses', as: :json
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'when no statuses exist for the current day' do
      before do
        sign_in(employee)
        create(:status, :plan, created_at: Date.yesterday)
      end

      it 'returns an empty array' do
        get '/today_statuses', as: :json
        expect(JSON.parse(response.body)).to eq([])
      end
    end
  end
end
