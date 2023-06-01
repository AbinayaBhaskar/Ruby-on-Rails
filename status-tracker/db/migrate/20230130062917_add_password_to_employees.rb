class AddPasswordToEmployees < ActiveRecord::Migration[7.0]
  def change
    change_table :employees, bulk: true do |t|
      t.string :encrypted_password, null: false
    end
  end
end
