class AddNullToEmployee < ActiveRecord::Migration[7.0]
  def up
    change_column :employees, :email, :string, null: false
  end

  def down
    change_column :employees, :email, :string
  end
end
