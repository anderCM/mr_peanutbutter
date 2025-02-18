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

ActiveRecord::Schema[7.2].define(version: 2025_02_18_025115) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auth_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.datetime "refresh_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["refresh_token"], name: "index_auth_tokens_on_refresh_token", unique: true
    t.index ["token"], name: "index_auth_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_auth_tokens_on_user_id"
  end

  create_table "exchanges", force: :cascade do |t|
    t.bigint "user_id"
    t.string "exchange_type", null: false
    t.decimal "amount_sent", precision: 30, scale: 2, null: false
    t.string "currency_sent", null: false
    t.decimal "amount_received", precision: 30, scale: 2, null: false
    t.string "currency_received", null: false
    t.decimal "exchange_rate", precision: 30, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_type"], name: "index_exchanges_on_exchange_type"
    t.index ["status"], name: "index_exchanges_on_status"
    t.index ["user_id"], name: "index_exchanges_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallet_exchanges", force: :cascade do |t|
    t.bigint "exchange_id"
    t.bigint "wallet_id"
    t.string "operation_type", null: false
    t.decimal "amount", precision: 30, scale: 2, null: false
    t.decimal "previous_balance", precision: 30, scale: 2, null: false
    t.decimal "new_balance", precision: 30, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id", "wallet_id"], name: "index_wallet_exchanges_on_exchange_id_and_wallet_id", unique: true
    t.index ["exchange_id"], name: "index_wallet_exchanges_on_exchange_id"
    t.index ["operation_type"], name: "index_wallet_exchanges_on_operation_type"
    t.index ["wallet_id"], name: "index_wallet_exchanges_on_wallet_id"
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "currency", null: false
    t.decimal "balance", precision: 30, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "currency"], name: "index_wallets_on_user_id_and_currency", unique: true
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "auth_tokens", "users"
  add_foreign_key "exchanges", "users"
  add_foreign_key "wallet_exchanges", "exchanges"
  add_foreign_key "wallet_exchanges", "wallets"
  add_foreign_key "wallets", "users"
end
