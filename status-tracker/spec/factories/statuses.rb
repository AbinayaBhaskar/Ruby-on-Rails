FactoryBot.define do
  factory :status do
    status_type { "plan" }
    content { "Plan(01/26):- 1. Complete ST-9: Implement the create and update action" }
    active { true }
    trait :plan do
      status_type { "plan" }
    end

    trait :actual do
      status_type { "actual" }
    end

    association :employee, factory: :employee
  end
end
