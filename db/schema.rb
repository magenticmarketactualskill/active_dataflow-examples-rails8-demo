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

ActiveRecord::Schema[8.1].define(version: 2025_12_01_153118) do
  create_table "active_data_flow_data_flow_runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "data_flow_id", null: false
    t.datetime "ended_at"
    t.text "error_backtrace"
    t.text "error_message"
    t.integer "first_id"
    t.integer "last_id"
    t.datetime "run_after", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "started_at"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["data_flow_id", "created_at"], name: "index_data_flow_runs_on_data_flow_id_and_created_at"
    t.index ["data_flow_id"], name: "index_active_data_flow_data_flow_runs_on_data_flow_id"
    t.index ["run_after"], name: "index_active_data_flow_data_flow_runs_on_run_after"
    t.index ["status"], name: "index_active_data_flow_data_flow_runs_on_status"
  end

  create_table "active_data_flow_data_flows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "last_error"
    t.datetime "last_run_at", precision: nil
    t.string "name", null: false
    t.integer "next_source_id"
    t.json "runtime"
    t.json "sink", null: false
    t.json "source", null: false
    t.string "status", default: "inactive"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_active_data_flow_data_flows_on_name", unique: true
    t.index ["next_source_id"], name: "index_active_data_flow_data_flows_on_next_source_id"
    t.index ["status"], name: "index_active_data_flow_data_flows_on_status"
  end

  create_table "product_exports", force: :cascade do |t|
    t.string "category_slug"
    t.datetime "created_at", null: false
    t.datetime "exported_at", null: false
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.integer "product_id", null: false
    t.string "sku", null: false
    t.datetime "updated_at", null: false
    t.index ["exported_at"], name: "index_product_exports_on_exported_at"
    t.index ["product_id"], name: "index_product_exports_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "sku", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["category", "active"], name: "index_products_on_category_and_active"
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  add_foreign_key "active_data_flow_data_flow_runs", "active_data_flow_data_flows", column: "data_flow_id"
  add_foreign_key "product_exports", "products"
end
