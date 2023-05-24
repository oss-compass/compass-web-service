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

ActiveRecord::Schema[7.0].define(version: 2023_05_10_091128) do
  create_table "allowlisted_jwts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "jti", null: false
    t.string "aud"
    t.datetime "exp", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_allowlisted_jwts_on_jti", unique: true
    t.index ["user_id"], name: "index_allowlisted_jwts_on_user_id"
  end

  create_table "beta_metrics", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "dimensionality"
    t.string "metric"
    t.string "desc"
    t.string "status"
    t.string "workflow"
    t.string "project"
    t.string "op_index"
    t.string "op_metric"
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collection_keyword_refs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "keyword_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "keyword_id"], name: "index_collection_keyword_refs_on_collection_id_and_keyword_id", unique: true
    t.index ["collection_id"], name: "index_collection_keyword_refs_on_collection_id"
    t.index ["keyword_id"], name: "index_collection_keyword_refs_on_keyword_id"
  end

  create_table "collections", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_collections_on_title"
  end

  create_table "crono_jobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log", size: :long
    t.datetime "last_performed_at", precision: nil
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "keywords", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_keywords_on_title"
  end

  create_table "login_binds", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "account", null: false
    t.string "nickname"
    t.string "avatar_url"
    t.string "uid"
    t.string "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account"], name: "index_login_binds_on_account"
    t.index ["provider"], name: "index_login_binds_on_provider"
    t.index ["uid", "provider_id"], name: "index_login_binds_on_uid_and_provider_id", unique: true
    t.index ["user_id"], name: "index_login_binds_on_user_id"
  end

  create_table "project_collection_refs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "project_name", null: false
    t.integer "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_project_collection_refs_on_collection_id"
    t.index ["project_name", "collection_id"], name: "index_project_collection_refs_on_project_name_and_collection_id", unique: true
    t.index ["project_name"], name: "index_project_collection_refs_on_project_name"
  end

  create_table "project_keyword_refs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "project_name", null: false
    t.integer "keyword_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["keyword_id"], name: "index_project_keyword_refs_on_keyword_id"
    t.index ["project_name", "keyword_id"], name: "index_project_keyword_refs_on_project_name_and_keyword_id", unique: true
    t.index ["project_name"], name: "index_project_keyword_refs_on_project_name"
  end

  create_table "project_tasks", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "task_id", null: false
    t.string "remote_url", null: false
    t.string "status"
    t.text "payload"
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "level"
    t.string "project_name"
    t.index ["project_name"], name: "index_project_tasks_on_project_name", unique: true
    t.index ["remote_url"], name: "index_project_tasks_on_remote_url", unique: true
  end

  create_table "reports", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "content"
    t.string "lang"
    t.string "associated_id"
    t.string "associated_type"
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "anonymous", default: false
    t.string "email_verification_token"
    t.datetime "email_verification_sent_at"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "allowlisted_jwts", "users", on_delete: :cascade
end
