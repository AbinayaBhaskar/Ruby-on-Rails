FactoryBot.define do
  factory :manager, class: 'Employee' do
    name {  Faker::Name.name }
    email { Faker::Internet.safe_email(name: "#{name}-#{Random.rand(10_000)}") }
    password { Faker::Internet.password }

    after(:create) do |manager|
      FactoryBot.create_list(:employee, 2, manager:)
    end
  end

  factory :employee do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email(name: "#{name}-#{Random.rand(10_000)}") }
    password { Faker::Internet.password }
    association :manager, factory: :manager
  end
end
