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

ActiveRecord::Schema[8.0].define(version: 2025_10_26_140700) do
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

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "happy_thing_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["happy_thing_id"], name: "index_comments_on_happy_thing_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "daily_happy_email_deliveries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipient_id", null: false
    t.datetime "delivered_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_daily_happy_email_deliveries_on_recipient_id"
    t.index ["user_id"], name: "index_daily_happy_email_deliveries_on_user_id"
  end

  create_table "data_access_logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "accessed_model"
    t.integer "accessed_id"
    t.string "action"
    t.string "ip_address"
    t.text "user_agent"
    t.jsonb "metadata", default: {}
    t.datetime "accessed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accessed_at"], name: "index_data_access_logs_on_accessed_at"
    t.index ["accessed_model", "accessed_id"], name: "index_data_access_logs_on_accessed_model_and_accessed_id"
    t.index ["user_id"], name: "index_data_access_logs_on_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "friend_id"
    t.boolean "accepted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "friend_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_group_memberships_on_friend_id"
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "happy_thing_group_shares", force: :cascade do |t|
    t.bigint "happy_thing_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_happy_thing_group_shares_on_group_id"
    t.index ["happy_thing_id"], name: "index_happy_thing_group_shares_on_happy_thing_id"
  end

  create_table "happy_thing_user_shares", force: :cascade do |t|
    t.bigint "happy_thing_id", null: false
    t.bigint "friend_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_happy_thing_user_shares_on_friend_id"
    t.index ["happy_thing_id"], name: "index_happy_thing_user_shares_on_happy_thing_id"
  end

  create_table "happy_things", force: :cascade do |t|
    t.string "title", null: false
    t.text "body"
    t.integer "status"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.string "place"
    t.float "latitude"
    t.float "longitude"
    t.bigint "category_id"
    t.boolean "share_location"
    t.string "visibility", default: "public"
    t.index ["category_id"], name: "index_happy_things_on_category_id"
    t.index ["user_id"], name: "index_happy_things_on_user_id"
    t.index ["visibility"], name: "index_happy_things_on_visibility"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "emoji"
    t.boolean "email_opt_in", default: false
    t.boolean "location_opt_in", default: false
    t.string "username"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "provider"
    t.string "uid"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "happy_things"
  add_foreign_key "comments", "users"
  add_foreign_key "daily_happy_email_deliveries", "users"
  add_foreign_key "daily_happy_email_deliveries", "users", column: "recipient_id"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users", column: "friend_id"
  add_foreign_key "groups", "users"
  add_foreign_key "happy_thing_group_shares", "groups"
  add_foreign_key "happy_thing_group_shares", "happy_things"
  add_foreign_key "happy_thing_user_shares", "happy_things"
  add_foreign_key "happy_thing_user_shares", "users", column: "friend_id"
  add_foreign_key "happy_things", "categories"
  add_foreign_key "happy_things", "users"
end
