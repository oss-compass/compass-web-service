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

ActiveRecord::Schema[7.1].define(version: 2024_06_13_072129) do
  create_table "active_storage_attachments", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allowlisted_jwts", charset: "utf8mb4", force: :cascade do |t|
    t.string "jti", null: false
    t.string "aud"
    t.datetime "exp", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_allowlisted_jwts_on_jti", unique: true
    t.index ["user_id"], name: "index_allowlisted_jwts_on_user_id"
  end

  create_table "beta_metrics", charset: "utf8mb4", force: :cascade do |t|
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

  create_table "crono_jobs", charset: "utf8mb4", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log", size: :long
    t.datetime "last_performed_at", precision: nil
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "lab_algorithms", charset: "utf8mb4", force: :cascade do |t|
    t.string "ident", null: false
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lab_datasets", charset: "utf8mb4", force: :cascade do |t|
    t.string "ident"
    t.string "name"
    t.integer "lab_model_version_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lab_metrics", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "ident", null: false
    t.string "category", null: false
    t.string "from"
    t.float "default_weight"
    t.float "default_threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "extra", default: "{}"
  end

  create_table "lab_model_comments", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "content", null: false
    t.integer "reply_to"
    t.integer "lab_model_id", null: false
    t.integer "lab_model_version_id"
    t.integer "lab_model_metric_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lab_model_id", "lab_model_version_id", "lab_model_metric_id"], name: "index_comments_on_m_v_m"
    t.index ["reply_to"], name: "index_lab_model_comments_on_reply_to"
    t.index ["user_id"], name: "index_lab_model_comments_on_user_id"
  end

  create_table "lab_model_invitations", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", null: false
    t.string "token", null: false
    t.integer "lab_model_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "user_id", null: false
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lab_model_id"], name: "index_lab_model_invitations_on_lab_model_id"
  end

  create_table "lab_model_members", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "lab_model_id", null: false
    t.integer "permission", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lab_model_id", "user_id"], name: "index_lab_model_members_on_lab_model_id_and_user_id", unique: true
  end

  create_table "lab_model_metrics", charset: "utf8mb4", force: :cascade do |t|
    t.integer "lab_metric_id", null: false
    t.integer "lab_model_version_id", null: false
    t.float "weight"
    t.float "threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lab_model_version_id", "lab_metric_id"], name: "index_metrics_on_v_m"
  end

  create_table "lab_model_versions", charset: "utf8mb4", force: :cascade do |t|
    t.string "version", default: ""
    t.integer "lab_model_id", null: false
    t.integer "lab_dataset_id", null: false
    t.integer "lab_algorithm_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lab_model_id", "version"], name: "index_lab_model_versions_on_lab_model_id_and_version"
  end

  create_table "lab_models", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.integer "dimension", null: false
    t.boolean "is_general", null: false
    t.boolean "is_public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_version_id"
  end

  create_table "login_binds", charset: "utf8mb4", force: :cascade do |t|
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

  create_table "project_tasks", charset: "utf8mb4", force: :cascade do |t|
    t.string "task_id"
    t.string "remote_url", collation: "utf8mb4_bin"
    t.string "status"
    t.text "payload"
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "level"
    t.string "project_name", collation: "utf8mb4_bin"
    t.index ["project_name"], name: "index_project_tasks_on_project_name", unique: true
    t.index ["remote_url"], name: "index_project_tasks_on_remote_url", unique: true
  end

  create_table "shortened_labels", charset: "utf8mb4", force: :cascade do |t|
    t.string "label", null: false, collation: "utf8mb4_bin"
    t.string "short_code", null: false
    t.string "level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label", "level"], name: "index_shortened_labels_on_label_and_level", unique: true
    t.index ["short_code"], name: "index_shortened_labels_on_short_code", unique: true
  end

  create_table "subject_access_levels", charset: "utf8mb4", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "access_level", default: 0, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "subject_id"], name: "index_subject_access_levels_on_user_id_and_subject_id", unique: true
  end

  create_table "subject_customizations", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_subject_customizations_on_subject_id", unique: true
  end

  create_table "subject_licenses", charset: "utf8mb4", force: :cascade do |t|
    t.string "license"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subject_refs", charset: "utf8mb4", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "child_id"
    t.integer "sub_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "child_id", "sub_type"], name: "index_subject_refs_on_parent_id_and_child_id_and_sub_type", unique: true
  end

  create_table "subject_sigs", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "maintainers"
    t.string "emails"
    t.integer "subject_ref_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_ref_id"], name: "index_subject_sigs_on_subject_ref_id", unique: true
  end
  

  create_table "subjects", charset: "utf8mb4", force: :cascade do |t|
    t.string "label", null: false, collation: "utf8mb4_bin"
    t.string "level", default: "repo", null: false, comment: "repo/community"
    t.string "status", default: "pending", null: false, comment: "pending/progress/complete"
    t.integer "count", default: 0, null: false
    t.datetime "status_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "collect_at"
    t.datetime "complete_at"
    t.index ["label"], name: "index_subjects_on_label", unique: true
  end

  create_table "subscriptions", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "subject_id"], name: "index_subscriptions_on_user_id_and_subject_id", unique: true
  end

  create_table "tpc_software_report_metrics", charset: "utf8mb4", force: :cascade do |t|
    t.string "code_url", null: false
    t.string "status", null: false
    t.integer "status_compass_callback", null: false
    t.integer "status_tpc_service_callback", null: false
    t.integer "version", null: false
    t.integer "tpc_software_report_id", null: false
    t.string "tpc_software_report_type", null: false
    t.integer "subject_id", null: false
    t.integer "user_id", null: false
    t.integer "base_repo_name"
    t.integer "base_website_url"
    t.integer "base_code_url"
    t.integer "compliance_license"
    t.integer "compliance_dco"
    t.integer "compliance_package_sig"
    t.integer "compliance_license_compatibility"
    t.integer "ecology_dependency_acquisition"
    t.integer "ecology_code_maintenance"
    t.integer "ecology_community_support"
    t.integer "ecology_adoption_analysis"
    t.integer "ecology_software_quality"
    t.integer "ecology_patent_risk"
    t.integer "lifecycle_version_normalization"
    t.integer "lifecycle_version_number"
    t.integer "lifecycle_version_lifecycle"
    t.integer "security_binary_artifact"
    t.integer "security_vulnerability"
    t.integer "security_vulnerability_response"
    t.integer "security_vulnerability_disclosure"
    t.integer "security_history_vulnerability"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tpc_software_selection_reports", charset: "utf8mb4", force: :cascade do |t|
    t.integer "report_type", null: false
    t.string "name", null: false
    t.integer "tpc_software_sig_id", null: false
    t.string "release", null: false
    t.datetime "release_time", null: false
    t.string "manufacturer", null: false
    t.string "website_url", null: false
    t.string "code_url", null: false
    t.string "programming_language", null: false
    t.integer "code_count"
    t.string "license"
    t.string "vulnerability_disclosure"
    t.string "vulnerability_response"
    t.string "short_code", null: false
    t.integer "subject_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tpc_software_selections", charset: "utf8mb4", force: :cascade do |t|
    t.integer "selection_type", null: false
    t.string "tpc_software_selection_report_ids", null: false
    t.string "repo_url"
    t.string "committers", null: false
    t.datetime "incubation_time", null: false
    t.integer "adaptation_method", null: false
    t.string "reason", null: false
    t.integer "subject_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tpc_software_sigs", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "value", null: false
    t.string "description", null: false
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
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
    t.string "language", default: "en"
    t.integer "role_level", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allowlisted_jwts", "users", on_delete: :cascade
end
