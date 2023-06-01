# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_14_163706) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.bigint "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", null: false
    t.string "jti", null: false
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["jti"], name: "index_employees_on_jti", unique: true
  end

  create_table "slack_messages", force: :cascade do |t|
    t.string "ts"
    t.bigint "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status_id"], name: "index_slack_messages_on_status_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "status_type"
    t.text "content"
    t.boolean "active", default: true
    t.bigint "plan_id"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_statuses_on_active"
    t.index ["employee_id"], name: "index_statuses_on_employee_id"
  end

  add_foreign_key "slack_messages", "statuses"
  add_foreign_key "statuses", "employees"
end
