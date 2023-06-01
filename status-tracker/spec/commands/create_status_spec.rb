require 'rails_helper'

RSpec.describe CreateStatus do
  subject(:create_status) do
    described_class.new(employee_id:, content:, status_type:, plan_id:)
  end

  describe "#call" do
    let(:employee_id) { FactoryBot.create(:employee).id }
    let(:content) do
      "Plan(01/26):- ST-9: Comeplete design and implementation of create action on status controller"
    end
    let(:status_type) { "plan" }
    let(:plan_id) { nil }

    context 'when creating planned status with an existing one' do
      it 'raises an error with a message' do
        FactoryBot.create(:status, :plan, employee_id:)
        expect do
          create_status.call
        end.to raise_error(CreateStatus::StatusExistsError,
                           "Status already exists")
      end
    end

    context 'when creating actual status with an existing one' do
      let(:status_type) { "actual" }
      let(:content) do
        "Actual(01/26):- 1. ST-9: Completed design and implementation of create action on status controller"
      end
      let(:plan_id) { FactoryBot.create(:status, :plan, employee_id:).id }

      it 'raises an error with a message' do
        FactoryBot.create(:status, :actual, employee_id:, plan_id: FactoryBot.create(:status, :plan, employee_id:).id)
        expect do
          create_status.call
        end.to raise_error(CreateStatus::StatusExistsError,
                           "Status already exists")
      end
    end

    context 'when creating actual status without active planned status' do
      let(:status_type) { "actual" }
      let(:content) do
        "Actual(01/26):- 1. ST-9: Completed design and implementation of create action on status controller"
      end

      it 'raises an error with a message' do
        expect do
          create_status.call
        end.to raise_error(CreateStatus::MissingPlanError,
                           "Cannot be created without a plan")
      end
    end

    context 'when creating planned status' do
      it 'returns the created status with details' do
        expect(create_status.call).to eq(Status.last)
      end

      it 'writes one planned status to DB' do
        create_status.call
        expect(Status.where(status_type: "plan").count).to eq(1)
      end
    end

    context 'when creating actual status' do
      let(:status_type) { "actual" }
      let(:content) do
        "Actual(01/26):- 1. ST-9: Completed design and implementation of create action on status controller"
      end
      let(:plan_id) { FactoryBot.create(:status, :plan, employee_id:).id }

      it 'returns the created status with details' do
        expect(create_status.call).to eq(Status.last)
      end

      it 'writes one actual status to DB' do
        create_status.call
        expect(Status.where(status_type: "actual").count).to eq(1)
      end
    end
  end
end
