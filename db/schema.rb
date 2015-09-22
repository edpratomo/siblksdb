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

ActiveRecord::Schema.define(version: 20150922040005) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "uuid-ossp"

  create_table "changes", force: true do |t|
    t.text     "table_name",                                  null: false
    t.datetime "action_tstamp", default: "clock_timestamp()", null: false
    t.text     "action",                                      null: false
    t.text     "original_data"
    t.text     "new_data"
    t.text     "query"
    t.text     "modified_by"
  end

  add_index "changes", ["action_tstamp"], name: "changes_action_tstamp", using: :btree
  add_index "changes", ["modified_by"], name: "changes_modified_by", using: :btree
  add_index "changes", ["table_name"], name: "changes_table_name", using: :btree

  create_table "districts", force: true do |t|
    t.string "code",              limit: 7,  null: false
    t.string "regency_city_code", limit: 4,  null: false
    t.string "name",              limit: 30, null: false
  end

  add_index "districts", ["code"], name: "districts_code_key", unique: true, using: :btree
  add_index "districts", ["name"], name: "districts_name", using: :btree

  create_table "exam_components", force: true do |t|
    t.text    "name",            null: false
    t.integer "sequence",        null: false
    t.float   "scale",           null: false
    t.integer "grade_weight_id"
  end

  create_table "exams", force: true do |t|
    t.integer  "pkg_id"
    t.text     "name",         default: "Generic",           null: false
    t.text     "annotation"
    t.datetime "expired_at"
    t.datetime "created_at",   default: "clock_timestamp()", null: false
    t.datetime "modified_at",  default: "clock_timestamp()", null: false
    t.text     "modified_by"
    t.datetime "published_at"
    t.text     "published_by"
  end

  create_table "exams_exam_components", force: true do |t|
    t.integer "exam_id"
    t.integer "exam_component_id"
  end

  add_index "exams_exam_components", ["exam_id", "exam_component_id"], name: "exam_unique", unique: true, using: :btree

  create_table "grade_weights", force: true do |t|
    t.text  "name",   null: false
    t.float "weight"
  end

  create_table "grades", force: true do |t|
    t.integer  "instructor_id",                                    null: false
    t.integer  "students_record_id",                               null: false
    t.integer  "exam_id",                                          null: false
    t.hstore   "grade",              default: {},                  null: false
    t.datetime "created_at",         default: "clock_timestamp()", null: false
    t.datetime "modified_at",        default: "clock_timestamp()", null: false
    t.text     "modified_by"
    t.integer  "student_id",                                       null: false
    t.float    "grade_sum"
  end

  add_index "grades", ["students_record_id", "exam_id"], name: "record_exam_unique", unique: true, using: :btree

  create_table "groups", force: true do |t|
    t.text "name", null: false
  end

  add_index "groups", ["name"], name: "groups_name_key", unique: true, using: :btree

  create_table "instructors", force: true do |t|
    t.text     "name",                                      null: false
    t.text     "nick",                                      null: false
    t.integer  "capacity",                                  null: false
    t.datetime "created_at",  default: "clock_timestamp()", null: false
    t.datetime "modified_at", default: "clock_timestamp()", null: false
    t.text     "modified_by"
  end

  add_index "instructors", ["name"], name: "instructors_name_key", unique: true, using: :btree
  add_index "instructors", ["nick"], name: "instructors_nick_key", unique: true, using: :btree

  create_table "instructors_schedules", force: true do |t|
    t.integer "schedule_id"
    t.integer "instructor_id"
    t.text    "day",           null: false
    t.integer "avail_seat",    null: false
  end

  add_index "instructors_schedules", ["schedule_id", "instructor_id", "day"], name: "instructor_schedule_day_unique", unique: true, using: :btree

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

  create_table "programs_instructors", force: true do |t|
    t.integer "program_id"
    t.integer "instructor_id"
  end

  create_table "provinces", force: true do |t|
    t.string "code", limit: 2,  null: false
    t.string "name", limit: 30, null: false
  end

  add_index "provinces", ["code"], name: "provinces_code_key", unique: true, using: :btree

  create_table "regencies_cities", force: true do |t|
    t.string "code",          limit: 4,  null: false
    t.string "province_code", limit: 2,  null: false
    t.string "name",          limit: 30, null: false
  end

  add_index "regencies_cities", ["code"], name: "regencies_cities_code_key", unique: true, using: :btree

  create_table "schedules", force: true do |t|
    t.text "label",     null: false
    t.text "time_slot", null: false
  end

  add_index "schedules", ["label"], name: "schedules_label_key", unique: true, using: :btree
  add_index "schedules", ["time_slot"], name: "schedules_time_slot_key", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "students", force: true do |t|
    t.text     "name",                                              null: false
    t.text     "birthplace"
    t.date     "birthdate"
    t.text     "sex",                                               null: false
    t.text     "phone"
    t.text     "email"
    t.datetime "created_at",          default: "clock_timestamp()", null: false
    t.datetime "modified_at",         default: "clock_timestamp()", null: false
    t.text     "modified_by"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.hstore   "biodata"
    t.text     "religion"
    t.text     "street_address"
    t.text     "district"
    t.text     "regency_city"
    t.text     "province"
    t.datetime "registered_at",       default: "clock_timestamp()", null: false
  end

  add_index "students", ["name"], name: "students_name", using: :btree
  add_index "students", ["registered_at"], name: "students_registered_at", using: :btree
  add_index "students", ["religion", "sex"], name: "students_religion_sex", using: :btree

  create_table "students_pkgs", force: true do |t|
    t.integer "student_id"
    t.integer "pkg_id"
  end

  add_index "students_pkgs", ["student_id", "pkg_id"], name: "student_pkg_unique", unique: true, using: :btree

  create_table "students_pkgs_instructors_schedules", force: true do |t|
    t.integer "students_pkg_id"
    t.integer "instructors_schedule_id"
  end

  add_index "students_pkgs_instructors_schedules", ["students_pkg_id", "instructors_schedule_id"], name: "student_pkg_instructor_unique", unique: true, using: :btree

  create_table "students_qualifications", force: true do |t|
    t.integer  "student_id"
    t.integer  "pkg_id"
    t.datetime "created_at",  default: "clock_timestamp()", null: false
    t.datetime "modified_at", default: "clock_timestamp()", null: false
    t.text     "modified_by"
  end

  create_table "students_records", force: true do |t|
    t.integer  "student_id"
    t.integer  "pkg_id"
    t.datetime "started_on",                                null: false
    t.datetime "finished_on"
    t.text     "status",      default: "active",            null: false
    t.datetime "created_at",  default: "clock_timestamp()", null: false
    t.datetime "modified_at", default: "clock_timestamp()", null: false
    t.text     "modified_by"
  end

  create_table "users", force: true do |t|
    t.integer  "group_id"
    t.text     "username",               null: false
    t.text     "fullname",               null: false
    t.text     "password_digest",        null: false
    t.text     "email"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  create_table "users_instructors", force: true do |t|
    t.integer "user_id"
    t.integer "instructor_id"
  end

  add_index "users_instructors", ["user_id", "instructor_id"], name: "user_instructor_unique", unique: true, using: :btree

end
