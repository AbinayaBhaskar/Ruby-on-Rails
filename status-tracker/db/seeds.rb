# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
super_manager = Employee.create!(
  name: 'Admin',
  email: 'admin@example.com',
  password: 'wVQQpnfvXcahBzR'
)

manager = Employee.create!(
  name: 'Ganesh',
  email: 'ganesh@example.com',
  manager_id: super_manager.id,
  password: 'lYt78WfOkF839P6'
)

team_member1 = Employee.create!(
  name: 'Lokesh',
  email: 'lokesh@example.com',
  manager_id: manager.id,
  password: 'oud2xKAMy0wAAEk'
)

team_member1_plan = team_member1.statuses.create!(
  content: 'I will complete employees API.',
  status_type: 'plan',
  active: true
)
team_member1_plan.create_slack_message!(ts: '1234567891.123456')

team_member1.statuses.create!(
  content: 'I have completed employees API.',
  status_type: 'actual',
  active: true,
  plan_id: team_member1_plan.id
)

team_member2 = Employee.create!(
  name: "Ramesh",
  email: "ramesh@gmail.com",
  manager_id: manager.id,
  password: 'oud2xKAMdddy0wAAEk'
)

team_member2_plan = team_member2.statuses.create!(
  content: "I will work on POST statuses API.",
  status_type: "plan",
  active: true
)

team_member2.statuses.create!(
  content: "I have completed POST statuses API.",
  status_type: "actual",
  active: false,
  plan_id: team_member2_plan.id
)

team_member2.statuses.create!(
  content: "I have successfully implemented both the POST and GET API for statuses.",
  status_type: "actual",
  active: true,
  plan_id: team_member2_plan.id
)
