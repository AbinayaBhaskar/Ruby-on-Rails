class Employee < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable, :validatable,
         jwt_revocation_strategy: self

  has_many :team_members, class_name: "Employee", foreign_key: "manager_id", inverse_of: :employee
  belongs_to :manager, class_name: "Employee", optional: true
  has_many :statuses

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true

  def accessible_team_members
    @accessible_team_members ||= begin
      team_members = []
      nested_accessible_employees(team_members, id)
      team_members
    end
  end

  private

  def nested_accessible_employees(team_members, emp_id)
    Employee.where(manager_id: emp_id).find_each do |employee|
      team_members << employee
      nested_accessible_employees(team_members, employee.id)
    end
  end
end
