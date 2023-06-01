require 'rails_helper'

RSpec.describe Status do
  describe '.within_dates' do
    let(:employee) { FactoryBot.create(:employee) }
    let(:plan) { FactoryBot.create(:status, :plan, employee:, created_at: 3.days.ago.to_date) }
    let(:actual) { FactoryBot.create(:status, :actual, plan_id: plan.id, created_at: 3.days.ago.to_date, employee:) }

    it 'return statuses from the specified dates' do
      expect(described_class.within_dates(employee.id, 6.days.ago.to_date, 3.days.ago.to_date)).to eq([actual])
    end
  end
end
