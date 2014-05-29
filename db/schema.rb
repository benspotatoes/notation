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

ActiveRecord::Schema.define(version: 20140529205717) do

  create_table "deleted_users", force: true do |t|
    t.integer  "primary_id",  null: false
    t.string   "user_id",     null: false
    t.string   "email",       null: false
    t.datetime "joined_at",   null: false
    t.integer  "entry_count", null: false
  end

  create_table "entries", force: true do |t|
    t.integer  "user_id",                    null: false
    t.text     "body",       default: ""
    t.boolean  "archived",   default: false
    t.string   "tags",       default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "entry_id",                   null: false
    t.integer  "entry_type", default: 0
  end

  add_index "entries", ["user_id", "entry_id"], name: "index_entries_on_user_id_and_entry_id", unique: true
  add_index "entries", ["user_id"], name: "index_entries_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_id",                             null: false
    t.string   "username"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["user_id"], name: "index_users_on_user_id", unique: true

end
