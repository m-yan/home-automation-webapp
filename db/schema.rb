# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161107071510) do

  create_table "device_statuses", force: :cascade do |t|
    t.integer  "device_id"
    t.string   "type"
    t.integer  "mode",                default: 1
    t.float    "temperature",         default: 25.0
    t.boolean  "power",               default: false
    t.integer  "volume",              default: 0
    t.datetime "start_time",          default: '2000-01-01 00:00:00'
    t.string   "on_timer_job_id"
    t.datetime "stop_time",           default: '2000-01-01 00:00:00'
    t.string   "off_timer_job_id"
    t.integer  "humidity",            default: 60
    t.integer  "opened",              default: 2
    t.boolean  "enabled",             default: true
    t.integer  "illuminance",         default: 1000
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "retry_job_id"
    t.integer  "on_timer",            default: 2
    t.integer  "off_timer",           default: 2
    t.integer  "start_time_relative"
    t.integer  "stop_time_relative"
    t.integer  "detected",            default: 2
    t.boolean  "auto",                default: false
    t.string   "auto_job_id"
  end

  add_index "device_statuses", ["device_id"], name: "index_device_statuses_on_device_id", using: :btree

  create_table "devices", force: :cascade do |t|
    t.string   "house_id"
    t.integer  "room_id"
    t.string   "note"
    t.string   "id_at_hgw"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "devices", ["house_id"], name: "index_devices_on_house_id", using: :btree
  add_index "devices", ["id_at_hgw"], name: "index_devices_on_id_at_hgw", using: :btree
  add_index "devices", ["room_id"], name: "index_devices_on_room_id", using: :btree
  add_index "devices", ["type"], name: "index_devices_on_type", using: :btree

  create_table "event_types", force: :cascade do |t|
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "house_id"
    t.integer  "user_id"
    t.integer  "device_id"
    t.integer  "event_type_id"
    t.datetime "occurred_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "events", ["device_id"], name: "index_events_on_device_id", using: :btree
  add_index "events", ["event_type_id"], name: "index_events_on_event_type_id", using: :btree
  add_index "events", ["house_id"], name: "index_events_on_house_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "houses", id: false, force: :cascade do |t|
    t.string   "hgw_id",     null: false
    t.string   "name"
    t.string   "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "houses", ["hgw_id"], name: "index_houses_on_hgw_id", unique: true, using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message"
    t.string   "detect_device"
    t.boolean  "read",          default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",                               null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                          null: false
    t.string   "scopes"
    t.string   "previous_refresh_token", default: "", null: false
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "operation_details", force: :cascade do |t|
    t.integer  "operation_id"
    t.string   "uri"
    t.string   "method"
    t.text     "request"
    t.string   "result_status"
    t.text     "response"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "operation_details", ["operation_id"], name: "index_operation_details_on_operation_id", using: :btree

  create_table "operation_types", force: :cascade do |t|
    t.string   "description"
    t.string   "device_type"
    t.string   "method"
    t.text     "modules_body"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "operation_types", ["device_type"], name: "index_operation_types_on_device_type", using: :btree

  create_table "operation_types_remote_buttons", id: false, force: :cascade do |t|
    t.integer "remote_button_id",  null: false
    t.integer "operation_type_id", null: false
    t.integer "order"
  end

  add_index "operation_types_remote_buttons", ["remote_button_id"], name: "index_operation_types_remote_buttons_on_remote_button_id", using: :btree

  create_table "operations", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "device_id"
    t.integer  "operation_type_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "operations", ["device_id"], name: "index_operations_on_device_id", using: :btree
  add_index "operations", ["event_id"], name: "index_operations_on_event_id", using: :btree
  add_index "operations", ["operation_type_id"], name: "index_operations_on_operation_type_id", using: :btree

  create_table "remote_buttons", force: :cascade do |t|
    t.string   "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string   "house_id"
    t.string   "floor"
    t.string   "facility_type"
    t.string   "note"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "rooms", ["house_id"], name: "index_rooms_on_house_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login_id"
    t.string   "name"
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "failed_attempts",     default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "house_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["house_id"], name: "index_users_on_house_id", using: :btree
  add_index "users", ["login_id"], name: "index_users_on_login_id", unique: true, using: :btree

  add_foreign_key "device_statuses", "devices"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
end
