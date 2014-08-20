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

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "changes", force: true do |t|
    t.text     "table_name",                      null: false
    t.datetime "action_tstamp", default: "now()", null: false
    t.text     "action",                          null: false
    t.text     "original_data"
    t.text     "new_data"
    t.text     "query"
    t.text     "modified_by"
  end

  create_table "groups", force: true do |t|
    t.text "name", null: false
  end

  add_index "groups", ["name"], name: "groups_name_key", unique: true, using: :btree

  create_table "pkgs", force: true do |t|
    t.text    "pkg",        null: false
    t.integer "program_id"
    t.integer "level",      null: false
  end

  create_table "prereqs", force: true do |t|
    t.integer "pkg_id"
    t.integer "req_pkg_id"
  end

  create_table "programs", force: true do |t|
    t.text "program", null: false
  end

  add_index "programs", ["program"], name: "programs_program_key", unique: true, using: :btree

  create_table "schedules", force: true do |t|
    t.text "label",     null: false
    t.text "time_slot", null: false
  end

  add_index "schedules", ["label"], name: "schedules_label_key", unique: true, using: :btree
  add_index "schedules", ["time_slot"], name: "schedules_time_slot_key", unique: true, using: :btree

  create_table "students", force: true do |t|
    t.text     "name",                                      null: false
    t.text     "sex",                                       null: false
    t.text     "phone"
    t.text     "note"
    t.datetime "ctime",                                     null: false
    t.datetime "mtime",       default: "clock_timestamp()", null: false
    t.integer  "modified_by"
  end

  create_table "students_pkgs", force: true do |t|
    t.integer  "student_id"
    t.integer  "pkg_id"
    t.datetime "ctime",                                     null: false
    t.datetime "mtime",       default: "clock_timestamp()", null: false
    t.integer  "modified_by"
  end

  create_table "students_pkgs_schedules", force: true do |t|
    t.integer  "student_pkg_id"
    t.integer  "schedule_id"
    t.text     "day",                                          null: false
    t.datetime "ctime",                                        null: false
    t.datetime "mtime",          default: "clock_timestamp()", null: false
    t.integer  "modified_by"
  end

  create_table "students_qualifications", force: true do |t|
    t.integer  "student_id"
    t.integer  "pkg_id"
    t.text     "acquired_from",                               null: false
    t.datetime "ctime",                                       null: false
    t.datetime "mtime",         default: "clock_timestamp()", null: false
    t.integer  "modified_by"
  end

  create_table "users", force: true do |t|
    t.integer "group_id"
    t.text    "name",        null: false
    t.text    "hashed_pass", null: false
    t.text    "email"
  end

end
