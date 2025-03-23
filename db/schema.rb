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

ActiveRecord::Schema[7.2].define(version: 2025_03_23_111420) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "families", force: :cascade do |t|
    t.string "reference_name"
    t.string "street"
    t.string "house_number"
    t.string "city"
    t.string "state"
    t.string "phone1"
    t.string "phone2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "neighborhood"
    t.boolean "financed_house", default: false
    t.decimal "financing_value", precision: 10, scale: 2
    t.decimal "rent_value", precision: 10, scale: 2
    t.boolean "has_loan", default: false
    t.decimal "loan_value", precision: 10, scale: 2
    t.date "food_basket_start_date"
    t.integer "food_basket_duration_months"
    t.decimal "family_income", precision: 10, scale: 2
    t.string "housing_type"
    t.string "food_basket_status", default: "não_receberam"
    t.index ["food_basket_status"], name: "index_families_on_food_basket_status"
  end

  create_table "members", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name"
    t.integer "age"
    t.string "role"
    t.boolean "firm_in_faith"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "birth_date"
    t.string "profession"
    t.boolean "employed", default: false
    t.decimal "income", precision: 10, scale: 2
    t.boolean "has_benefit", default: false
    t.decimal "benefit_value", precision: 10, scale: 2
    t.boolean "can_read", default: true
    t.boolean "lives_in_house", default: true
    t.boolean "lives_with_partner", default: false
    t.string "cpf"
    t.boolean "attends_church", default: false
    t.string "shirt_size"
    t.string "shoe_size"
    t.string "disability"
    t.integer "pants_size"
    t.string "gender"
    t.index ["family_id"], name: "index_members_on_family_id"
    t.index ["gender"], name: "index_members_on_gender"
  end

  create_table "needs", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name"
    t.string "beneficiary"
    t.boolean "attended"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_needs_on_family_id"
  end

  create_table "observations", force: :cascade do |t|
    t.bigint "visit_id", null: false
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visit_id"], name: "index_observations_on_visit_id"
  end

  create_table "pending_needs", force: :cascade do |t|
    t.bigint "visit_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visit_id"], name: "index_pending_needs_on_visit_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visited_projects", force: :cascade do |t|
    t.bigint "visit_id", null: false
    t.bigint "project_id", null: false
    t.bigint "region_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_visited_projects_on_project_id"
    t.index ["region_id"], name: "index_visited_projects_on_region_id"
    t.index ["visit_id"], name: "index_visited_projects_on_visit_id"
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "user_id", null: false
    t.date "visit_date"
    t.text "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_visits_on_family_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "members", "families"
  add_foreign_key "needs", "families"
  add_foreign_key "observations", "visits"
  add_foreign_key "pending_needs", "visits"
  add_foreign_key "visited_projects", "projects"
  add_foreign_key "visited_projects", "regions"
  add_foreign_key "visited_projects", "visits"
  add_foreign_key "visits", "families"
  add_foreign_key "visits", "users"
end
