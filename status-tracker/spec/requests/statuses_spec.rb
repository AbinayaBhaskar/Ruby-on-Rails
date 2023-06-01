require 'rails_helper'

RSpec.describe "Statuses" do
  describe "POST /statuses" do
    let(:employee) { FactoryBot.create(:employee) }
    let(:plan) { FactoryBot.create(:status, :plan, employee:) }
    let(:actual) { FactoryBot.create(:status, :actual, plan_id: plan.id, employee:) }
    let(:status_params) do
      {
        employee_id: employee.id,
        status_type: "plan",
        content: "Plan(01/25):- 1. Complete the FS-09",
        plan_id: nil
      }
    end
    let(:response_payload) do
      {
        content: status_params[:content],
        plan_id: status_params[:plan_id],
        status_type: status_params[:status_type],
      }.stringify_keys
    end

    context 'when creating planned status' do
      before do
        login_as(employee)
      end

      it 'returns the status with content' do
        post "/statuses", params: status_params, as: :json
        expect(JSON.parse(response.body)).to match(hash_including(response_payload))
      end
    end

    context 'when creating actual status' do
      before do
        login_as(employee)
        status_params.merge!(status_type: "actual", content: "Actual(01/26):- 1.\
                             ST-9: Completed design and implementation of create action on status controller",
                             plan_id: plan.id)
      end

      it 'returns the status with content' do
        post "/statuses", params: status_params, as: :json
        expect(JSON.parse(response.body)).to match(hash_including(response_payload))
      end
    end

    context 'when creating status with missing content' do
      before do
        login_as(employee)
        status_params.merge!(content: "")
      end

      it 'returns 422 with a message' do
        post "/statuses", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Content is Missing")
      end
    end

    context 'when creating planned status with an existing one' do
      before do
        login_as(employee)
      end

      it 'returns 422 with a message' do
        FactoryBot.create(:status, :plan, employee:)
        post "/statuses", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Status already exists")
      end
    end

    context 'when creating actual status with an existing one' do
      before do
        login_as(employee)
      end

      it 'returns 422 with a message' do
        FactoryBot.create(:status, :actual, plan_id: plan.id)
        post "/statuses", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Status already exists")
      end
    end

    context 'when creating actual status without active planned status' do
      before do
        login_as(employee)
        status_params.merge!(status_type: "actual", content: "Actual(01/26):- 1.\
                             ST-9: Completed design and implementation of create action on status controller")
      end

      it 'returns 422 with a message' do
        post "/statuses", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Cannot be created without a plan")
      end
    end

    context 'when employee is not signed in' do
      it 'returns 401 with a message' do
        post "/statuses", params: status_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /statuses/[:id]" do
    let(:employee) { create(:employee) }
    let(:plan) { FactoryBot.create(:status, :plan, employee:) }
    let(:actual) { FactoryBot.create(:status, :actual, plan_id: plan.id, employee:) }
    let(:status_params) do
      {
        content: "Plan(01/25):- 1. Complete the FS-09"
      }
    end
    let(:response_payload) do
      {
        content: status_params[:content]
      }.stringify_keys
    end

    context 'when updating planned status' do
      before do
        login_as(employee)
      end

      it 'returns the updated details' do
        put "/statuses/#{plan.id}", params: status_params, as: :json
        expect(JSON.parse(response.body)).to match(hash_including(response_payload))
      end
    end

    context 'when updating actual status' do
      before do
        login_as(employee)
        status_params.merge!(content: "Actual(01/26):- 1.\
                             ST-9: Completed design and implementation of create action on status controller")
      end

      it 'returns the updated details' do
        put "/statuses/#{actual.id}", params: status_params, as: :json
        expect(JSON.parse(response.body)).to match(hash_including(response_payload))
      end
    end

    context 'when updating status without content' do
      before do
        login_as(employee)
        status_params.merge!(content: "")
      end

      it 'returns 422 with a message' do
        put "/statuses/#{plan.id}", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Content is Missing")
      end
    end

    context 'when updating inactive planned status' do
      before do
        login_as(employee)
        plan.update(active: false)
      end

      it 'returns 422 with a message' do
        put "/statuses/#{plan.id}", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Cannot update an inactive status")
      end
    end

    context 'when updating inactive actual status' do
      before do
        login_as(employee)
        actual.update(active: false)
        status_params.merge!(content: "Actual(01/26):- 1.\
                             ST-9: Completed design and implementation of create action on status controller")
      end

      it 'returns 422 with a message' do
        put "/statuses/#{actual.id}", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Cannot update an inactive status")
      end
    end

    context "when updating planned status with it's actual status defined" do
      before do
        login_as(employee)
        actual
      end

      it 'returns 422 with a message' do
        put "/statuses/#{plan.id}", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Actual already defined cannot update the plan")
      end
    end

    context 'when status not found' do
      before do
        login_as(employee)
      end

      it 'returns 422 with a message' do
        put "/statuses/1", params: status_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).to eq("Status Not Found")
      end
    end

    context 'when employee is not signed in' do
      it 'returns 401 with a message' do
        put "/statuses/#{plan.id}", params: status_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /index" do
    let(:employee) { FactoryBot.create(:employee) }
    let(:statuses) do
      statuses = []
      date = 5.days.ago.to_date
      4.times do
        plan = FactoryBot.create(:status, :plan, created_at: date, employee:)
        statuses << plan
        statuses << FactoryBot.create(:status, :actual, plan_id: plan.id, created_at: date, employee:)
        date += 1
      end
      statuses
    end
    let(:response_payload) do
      response = []
      [statuses[1], statuses[3], statuses[5]].each do |status|
        response << {
          id: status.id,
          content: status.content,
          status_type: status.status_type,
          plan_id: status.plan_id
        }.stringify_keys
      end
      response
    end
    let(:from_date) { 5.days.ago.to_date }
    let(:to_date) { 3.days.ago.to_date }

    before do
      login_as(employee)
    end

    context 'when filtering statuses within dates' do
      it 'returns an array of statuses within dates' do
        statuses
        get "/statuses?from_date=#{from_date}&to_date=#{to_date}&employee_id=#{employee.id}", as: :json
        expect(JSON.parse(response.body)).to match(response_payload)
      end

      it 'returns only the active actual statuses' do
        FactoryBot.create(:status, :plan, created_at: 3.days.ago.to_date, employee:)
        get "/statuses?from_date=#{from_date}&to_date=#{to_date}&employee_id=#{employee.id}", as: :json
        expect(JSON.parse(response.body)).to match([])
      end
    end

    context 'when filtering statuses with range above 40 days' do
      let(:from_date) { 40.days.ago.to_date }
      let(:to_date) { Time.zone.today }

      it 'returns a message with status 422' do
        get "/statuses?from_date=#{from_date}&to_date=#{to_date}&employee_id=#{employee.id}", as: :json
        expect(JSON.parse(response.body)).to match({ message: "Range exceeded 40 days" }.stringify_keys)
      end
    end
  end
end
