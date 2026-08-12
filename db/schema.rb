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

ActiveRecord::Schema[8.1].define(version: 2026_08_07_105030) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.float "duration_ms"
    t.string "error_class"
    t.text "error_message"
    t.string "method", null: false
    t.boolean "pending", default: false
    t.jsonb "request_body"
    t.jsonb "request_headers"
    t.text "response_body"
    t.jsonb "response_headers"
    t.integer "status_code"
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["created_at"], name: "index_api_requests_on_created_at"
    t.index ["status_code"], name: "index_api_requests_on_status_code"
  end

  create_table "ob_api_tokens", force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "expired_at"
    t.string "id_token"
    t.datetime "issued_at"
    t.bigint "ob_consent_id"
    t.string "refresh_token"
    t.string "scope"
    t.datetime "updated_at", null: false
    t.index ["ob_consent_id"], name: "index_ob_api_tokens_on_ob_consent_id"
  end

  create_table "ob_consents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expired_at"
    t.string "external_id"
    t.jsonb "permissions"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_ob_consents_on_external_id"
  end

  create_table "provider_configs", force: :cascade do |t|
    t.string "authorization_endpoint"
    t.string "code"
    t.datetime "created_at", null: false
    t.jsonb "scopes_supported", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_provider_configs_on_code"
  end
end
