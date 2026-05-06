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

ActiveRecord::Schema[8.0].define(version: 2026_05_05_230200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "going", null: false
    t.index ["event_id", "status", "created_at"], name: "index_attendances_on_event_status_created_at"
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["user_id", "event_id"], name: "index_attendances_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "category"
    t.datetime "date"
    t.string "location"
    t.decimal "price"
    t.text "description"
    t.boolean "approved", default: false, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "status", default: "draft", null: false
    t.datetime "published_at"
    t.text "review_note"
    t.string "ticket_url"
    t.integer "capacity"
    t.string "city", default: "İstanbul", null: false
    t.string "external_source"
    t.string "external_id"
    t.string "external_url"
    t.string "remote_poster_url"
    t.boolean "external_is_free"
    t.string "ticket_url_kind"
    t.datetime "imported_at"
    t.datetime "end_date"
    t.index ["approved"], name: "index_events_on_approved"
    t.index ["city"], name: "index_events_on_city"
    t.index ["end_date"], name: "index_events_on_end_date"
    t.index ["external_source", "external_id"], name: "index_events_on_external_source_and_external_id", unique: true, where: "((external_source IS NOT NULL) AND (external_id IS NOT NULL))"
    t.index ["imported_at"], name: "index_events_on_imported_at"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["status", "date"], name: "index_events_on_status_and_date"
    t.index ["status"], name: "index_events_on_status"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "external_event_candidates", force: :cascade do |t|
    t.string "source", null: false
    t.string "external_id", null: false
    t.string "status", default: "pending", null: false
    t.integer "priority", default: 0, null: false
    t.string "title"
    t.string "city"
    t.string "venue"
    t.string "venue_type"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "category"
    t.string "format"
    t.string "poster_url"
    t.string "ticket_url"
    t.string "external_url"
    t.string "ticket_url_kind"
    t.jsonb "raw_data", default: {}, null: false
    t.jsonb "mapped_data", default: {}, null: false
    t.jsonb "review_reasons", default: [], null: false
    t.jsonb "priority_reasons", default: [], null: false
    t.string "duplicate_warning"
    t.string "hidden_reason"
    t.datetime "first_seen_at"
    t.datetime "last_seen_at"
    t.bigint "resolved_event_id"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_external_event_candidates_on_city"
    t.index ["priority"], name: "index_external_event_candidates_on_priority"
    t.index ["resolved_event_id"], name: "index_external_event_candidates_on_resolved_event_id"
    t.index ["source", "external_id"], name: "index_external_event_candidates_on_source_and_external_id", unique: true
    t.index ["starts_at"], name: "index_external_event_candidates_on_starts_at"
    t.index ["status"], name: "index_external_event_candidates_on_status"
    t.index ["venue_type"], name: "index_external_event_candidates_on_venue_type"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "import_runs", force: :cascade do |t|
    t.string "source", null: false
    t.string "status", default: "running", null: false
    t.boolean "dry_run", default: true, null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "fetched_count", default: 0, null: false
    t.integer "new_candidate_count", default: 0, null: false
    t.integer "duplicate_count", default: 0, null: false
    t.integer "skipped_count", default: 0, null: false
    t.integer "hidden_count", default: 0, null: false
    t.integer "failed_count", default: 0, null: false
    t.jsonb "parameters", default: {}, null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source"], name: "index_import_runs_on_source"
    t.index ["started_at"], name: "index_import_runs_on_started_at"
    t.index ["status"], name: "index_import_runs_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "users"
  add_foreign_key "events", "users"
  add_foreign_key "external_event_candidates", "events", column: "resolved_event_id"
end
