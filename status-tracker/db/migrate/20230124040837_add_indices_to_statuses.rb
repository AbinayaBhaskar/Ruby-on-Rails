class AddIndicesToStatuses < ActiveRecord::Migration[7.0]
  def change
    add_index :statuses, :active
  end
end
