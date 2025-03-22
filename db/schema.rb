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

ActiveRecord::Schema[8.0].define(version: 2025_03_22_184144) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "conversations", force: :cascade do |t|
    t.string "title"
    t.integer "total_input_tokens", default: 0
    t.integer "total_output_tokens", default: 0
    t.bigint "projects_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["projects_id"], name: "index_conversations_on_projects_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "role", null: false
    t.text "content", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.bigint "conversations_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversations_id"], name: "index_messages_on_conversations_id"
    t.index ["role"], name: "index_messages_on_role"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "specs", force: :cascade do |t|
    t.text "content"
    t.text "user_flow"
    t.text "model_erd"
    t.text "roadmap_flow"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_specs_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "conversations", "projects", column: "projects_id"
  add_foreign_key "messages", "conversations", column: "conversations_id"
  add_foreign_key "projects", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "specs", "projects"
end
