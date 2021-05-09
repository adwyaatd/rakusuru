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

ActiveRecord::Schema.define(version: 2021_05_09_060204) do

  create_table "s1_switches", charset: "utf8mb4", force: :cascade do |t|
    t.string "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "s2dmms", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.text "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "s3_sender_infos", charset: "utf8mb4", force: :cascade do |t|
    t.string "sender_name"
    t.string "tel"
    t.string "email"
    t.text "title"
    t.text "content"
    t.integer "user_group_id"
    t.integer "disable"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "is_active", default: 0
  end

  create_table "s3bases", charset: "utf8mb4", force: :cascade do |t|
    t.string "shop_name"
    t.text "contact_url"
    t.text "shop_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "about_shop"
    t.integer "scraping_id"
    t.integer "submit_status"
    t.integer "disable"
    t.datetime "submit_at"
  end

  create_table "s4tunos", charset: "utf8mb4", force: :cascade do |t|
    t.string "gift_name"
    t.integer "donation_amount"
    t.integer "ranking"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "municipalites"
  end

end
