class CreateStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :statuses do |t|
      t.string :status_type
      t.text :content
      t.boolean :active, default: "true"
      t.bigint :plan_id
      t.references :employee, foreign_key: true

      t.timestamps
    end
  end
end
