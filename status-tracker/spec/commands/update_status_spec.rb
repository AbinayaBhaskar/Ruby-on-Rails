require 'rails_helper'

RSpec.describe UpdateStatus do
  subject(:update_status) do
    described_class.new(status_id:, content:)
  end

  describe "#call" do
    let(:plan) { FactoryBot.create(:status, :plan) }
    let(:status_id) { nil }
    let(:content) do
      "Plan(01/26):- ST-9: Comeplete design and implementation of create action on status controller"
    end

    context 'when status not found' do
      it 'raises an error with a message' do
        expect do
          update_status.call
        end.to raise_error(UpdateStatus::StatusNotFoundError,
                           "Status Not Found")
      end
    end

    context 'when updating inactive planned status' do
      let(:plan) { FactoryBot.create(:status, :plan, active: false) }
      let(:status_id) { plan.id }

      it 'raises an error with a message' do
        expect do
          update_status.call
        end.to raise_error(UpdateStatus::InactiveStatusError,
                           "Cannot update an inactive status")
      end
    end

    context 'when updating inactive actual status' do
      let(:status_id) { FactoryBot.create(:status, :actual, active: false, plan_id: plan.id).id }
      let(:content) do
        "Actual(01/26):- 1. ST-9: Completed design and implementation of create action on status controller"
      end

      it 'raises an error with a message' do
        expect do
          update_status.call
        end.to raise_error(UpdateStatus::InactiveStatusError,
                           "Cannot update an inactive status")
      end
    end

    context "when updating planned status with it's actual status defined" do
      let(:status_id) { plan.id }

      it 'raises an error with a message' do
        FactoryBot.create(:status, :actual, plan_id: plan.id)
        expect do
          update_status.call
        end.to raise_error(UpdateStatus::ActualExistsError,
                           "Actual already defined cannot update the plan")
      end
    end

    context 'when updating planned status' do
      let(:status_id) { plan.id }

      it 'sets the previous status inactive' do
        update_status.call
        expect(plan.reload.active).to be(false)
      end

      it 'returns the updated status' do
        update_status.call
        expect(content).to eq(Status.last.content)
      end
    end

    context 'when updating actual status' do
      let(:status_id) { FactoryBot.create(:status, :actual, plan_id: plan.id).id }
      let(:content) do
        "Actual(01/26):- 1. ST-9: Completed design and implementation of create action on status controller"
      end

      it 'sets the previous status inactive' do
        update_status.call
        expect(Status.find(status_id).reload.active).to be(false)
      end

      it 'returns the updated status' do
        update_status.call
        expect(content).to eq(Status.last.content)
      end
    end
  end
end
