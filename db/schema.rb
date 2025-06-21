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

ActiveRecord::Schema[8.0].define(version: 2025_06_21_205741) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "artifact_stencils", force: :cascade do |t|
    t.string "name", null: false
    t.text "prompt", null: false
    t.string "description", null: false
    t.boolean "published", default: false, null: false
    t.bigint "user_id", null: false
    t.integer "usage_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", default: 0, null: false
    t.index ["user_id"], name: "index_artifact_stencils_on_user_id"
  end

  create_table "artifacts", force: :cascade do |t|
    t.text "content"
    t.bigint "project_id", null: false
    t.bigint "favorite_artifact_stencil_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "artifact_stencil_id"
    t.index ["favorite_artifact_stencil_id"], name: "index_artifacts_on_favorite_artifact_stencil_id"
    t.index ["project_id"], name: "index_artifacts_on_project_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "title"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reached_token_limit", default: false
    t.index ["project_id"], name: "index_conversations_on_project_id"
  end

  create_table "favorite_artifact_stencils", force: :cascade do |t|
    t.bigint "artifact_stencil_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artifact_stencil_id"], name: "index_favorite_artifact_stencils_on_artifact_stencil_id"
    t.index ["user_id", "artifact_stencil_id"], name: "idx_on_user_id_artifact_stencil_id_67c1ed707a", unique: true
    t.index ["user_id"], name: "index_favorite_artifact_stencils_on_user_id"
  end

  create_table "invites", force: :cascade do |t|
    t.string "invite_code", null: false
    t.integer "created_by_id", null: false
    t.integer "used_by_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_invites_on_created_by_id"
    t.index ["invite_code"], name: "index_invites_on_invite_code", unique: true
    t.index ["used_by_id"], name: "index_invites_on_used_by_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "role", null: false
    t.text "content", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "suggestions", default: [], array: true
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["role"], name: "index_messages_on_role"
  end

  create_table "open_router_usage_logs", force: :cascade do |t|
    t.string "model", null: false
    t.integer "prompt_tokens", null: false
    t.integer "completion_tokens", null: false
    t.integer "total_tokens", null: false
    t.decimal "cost", precision: 10, scale: 5, null: false
    t.string "user_type", null: false
    t.bigint "user_id", null: false
    t.string "request_id", null: false
    t.jsonb "raw_usage_response", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_open_router_usage_logs_on_request_id", unique: true
    t.index ["user_type", "user_id"], name: "index_open_router_usage_logs_on_user"
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

  create_table "total_tokens", force: :cascade do |t|
    t.integer "total", default: 0
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_total_tokens_on_conversation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.integer "account_type", default: 0, null: false
    t.decimal "current_daily_cost", precision: 10, scale: 5, default: "0.0", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "weekly_consumptions", force: :cascade do |t|
    t.integer "credits", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_weekly_consumptions_on_user_id"
  end

  add_foreign_key "artifact_stencils", "users"
  add_foreign_key "artifacts", "artifact_stencils"
  add_foreign_key "artifacts", "favorite_artifact_stencils"
  add_foreign_key "artifacts", "projects"
  add_foreign_key "conversations", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "total_tokens", "conversations"
  add_foreign_key "weekly_consumptions", "users"
end
