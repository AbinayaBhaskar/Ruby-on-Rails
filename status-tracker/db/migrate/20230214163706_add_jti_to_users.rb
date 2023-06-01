class AddJtiToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :jti, :string
    # rubocop:disable Rails/SkipsModelValidations
    Employee.all.each do |employee|
      employee.update_column(:jti, SecureRandom.uuid)
    end
    # rubocop:enable Rails/SkipsModelValidations
    change_column_null :employees, :jti, false
    add_index :employees, :jti, unique: true
  end
end
