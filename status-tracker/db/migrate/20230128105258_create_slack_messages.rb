class CreateSlackMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :slack_messages do |t|
      t.string :ts
      t.references :status, foreign_key: true

      t.timestamps
    end
  end
end
