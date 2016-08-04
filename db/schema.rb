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

ActiveRecord::Schema.define(version: 20160803163901) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "pg_trgm"
  enable_extension "hstore"
  enable_extension "pg_redispub"

  create_table "changes", force: :cascade do |t|
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

  create_table "components", force: :cascade do |t|
    t.text     "content",     default: "",                  null: false
    t.datetime "created_at",  default: "clock_timestamp()", null: false
    t.text     "modified_by"
    t.integer  "course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.text    "name",                            null: false
    t.text    "idn_prefix",         default: "", null: false
    t.integer "head_instructor_id"
  end

  create_table "districts", force: :cascade do |t|
    t.string "code",              limit: 7,  null: false
    t.string "regency_city_code", limit: 4,  null: false
    t.string "name",              limit: 30, null: false
  end

  add_index "districts", ["code"], name: "districts_code_key", unique: true, using: :btree
  add_index "districts", ["name"], name: "districts_name", using: :btree

  create_table "grades", force: :cascade do |t|
    t.integer  "students_record_id",                               null: false
    t.integer  "student_id"
    t.datetime "created_at",         default: "clock_timestamp()", null: false
    t.text     "modified_by"
    t.integer  "instructor_id",                                    null: false
    t.integer  "component_id"
    t.hstore   "value",              default: {},                  null: false
  end

  add_index "grades", ["students_record_id"], name: "grades_students_record_id_key", unique: true, using: :btree

  create_table "groups", force: :cascade do |t|
    t.text "name", null: false
  end

  add_index "groups", ["name"], name: "groups_name_key", unique: true, using: :btree

  create_table "instructors", force: :cascade do |t|
    t.text     "name",                                      null: false
    t.text     "nick",                                      null: false
    t.integer  "capacity",                                  null: false
    t.datetime "created_at",  default: "clock_timestamp()", null: false
    t.datetime "modified_at", default: "clock_timestamp()", null: false
    t.text     "modified_by"
  end

  add_index "instructors", ["name"], name: "instructors_name_key", unique: true, using: :btree
  add_index "instructors", ["nick"], name: "instructors_nick_key", unique: true, using: :btree

  create_table "instructors_schedules", force: :cascade do |t|
    t.integer "schedule_id"
    t.integer "instructor_id"
    t.text    "day",           null: false
    t.integer "avail_seat",    null: false
  end

  add_index "instructors_schedules", ["schedule_id", "instructor_id", "day"], name: "instructor_schedule_day_unique", unique: true, using: :btree

  create_table "pkgs", force: :cascade do |t|
    t.text    "pkg",        null: false
    t.integer "program_id"
    t.integer "level",      null: false
    t.integer "course_id"
  end

  create_table "prereqs", force: :cascade do |t|
    t.integer "pkg_id"
    t.integer "req_pkg_id"
  end

  create_table "programs", force: :cascade do |t|
    t.text "program", null: false
  end

  add_index "programs", ["program"], name: "programs_program_key", unique: true, using: :btree

  create_table "programs_instructors", force: :cascade do |t|
    t.integer "program_id"
    t.integer "instructor_id"
  end

  create_table "provinces", force: :cascade do |t|
    t.string "code", limit: 2,  null: false
    t.string "name", limit: 30, null: false
  end

  add_index "provinces", ["code"], name: "provinces_code_key", unique: true, using: :btree

  create_table "regencies_cities", force: :cascade do |t|
    t.string "code",          limit: 4,  null: false
    t.string "province_code", limit: 2,  null: false
    t.string "name",          limit: 30, null: false
  end

  add_index "regencies_cities", ["code"], name: "regencies_cities_code_key", unique: true, using: :btree

  create_table "schedules", force: :cascade do |t|
    t.text "label",     null: false
    t.text "time_slot", null: false
  end

  add_index "schedules", ["label"], name: "schedules_label_key", unique: true, using: :btree
  add_index "schedules", ["time_slot"], name: "schedules_time_slot_key", unique: true, using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255, null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "students", force: :cascade do |t|
    t.text     "name",                                                          null: false
    t.text     "birthplace"
    t.date     "birthdate"
    t.text     "sex",                                                           null: false
    t.text     "phone"
    t.text     "email"
    t.datetime "created_at",                      default: "clock_timestamp()", null: false
    t.datetime "modified_at",                     default: "clock_timestamp()", null: false
    t.text     "modified_by"
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.hstore   "biodata"
    t.text     "religion"
    t.text     "street_address"
    t.text     "district"
    t.text     "regency_city"
    t.text     "province"
    t.datetime "registered_at",                   default: "clock_timestamp()", null: false
    t.text     "employment",                      default: "belum bekerja",     null: false
  end

  add_index "students", ["name"], name: "students_name", using: :btree
  add_index "students", ["registered_at"], name: "students_registered_at", using: :btree
  add_index "students", ["religion", "sex"], name: "students_religion_sex", using: :btree

  create_table "students_pkgs", force: :cascade do |t|
    t.integer "student_id"
    t.integer "pkg_id"
  end

  add_index "students_pkgs", ["student_id", "pkg_id"], name: "student_pkg_unique", unique: true, using: :btree

  create_table "students_pkgs_instructors_schedules", force: :cascade do |t|
    t.integer "students_pkg_id"
    t.integer "instructors_schedule_id"
  end

  add_index "students_pkgs_instructors_schedules", ["students_pkg_id", "instructors_schedule_id"], name: "student_pkg_instructor_unique", unique: true, using: :btree

  create_table "students_qualifications", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "pkg_id"
    t.datetime "created_at",  default: "clock_timestamp()", null: false
    t.datetime "modified_at", default: "clock_timestamp()", null: false
    t.text     "modified_by"
  end

  create_table "students_records", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "pkg_id"
    t.datetime "started_on",                                null: false
    t.datetime "finished_on"
    t.text     "status",      default: "active",            null: false
    t.datetime "created_at",  default: "clock_timestamp()", null: false
    t.datetime "modified_at", default: "clock_timestamp()", null: false
    t.text     "modified_by"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "group_id"
    t.text     "username",               null: false
    t.text     "fullname",               null: false
    t.text     "password_digest",        null: false
    t.text     "email"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  create_table "users_instructors", force: :cascade do |t|
    t.integer "user_id"
    t.integer "instructor_id"
  end

  add_index "users_instructors", ["user_id", "instructor_id"], name: "user_instructor_unique", unique: true, using: :btree

  add_foreign_key "components", "courses", name: "components_course_id_fkey"
  add_foreign_key "courses", "instructors", column: "head_instructor_id", name: "courses_head_instructor_id_fkey"
  add_foreign_key "districts", "regencies_cities", column: "regency_city_code", primary_key: "code", name: "districts_regency_city_code_fkey"
  add_foreign_key "grades", "components", name: "grades_component_id_fkey"
  add_foreign_key "grades", "instructors", name: "grades_instructor_id_fkey"
  add_foreign_key "grades", "students", name: "grades_student_id_fkey"
  add_foreign_key "grades", "students_records", name: "grades_students_record_id_fkey"
  add_foreign_key "instructors_schedules", "instructors", name: "instructors_schedules_instructor_id_fkey"
  add_foreign_key "instructors_schedules", "schedules", name: "instructors_schedules_schedule_id_fkey"
  add_foreign_key "pkgs", "courses", name: "pkgs_course_id_fkey"
  add_foreign_key "pkgs", "programs", name: "pkgs_program_id_fkey"
  add_foreign_key "prereqs", "pkgs", column: "req_pkg_id", name: "prereqs_req_pkg_id_fkey"
  add_foreign_key "prereqs", "pkgs", name: "prereqs_pkg_id_fkey"
  add_foreign_key "programs_instructors", "instructors", name: "programs_instructors_instructor_id_fkey"
  add_foreign_key "programs_instructors", "programs", name: "programs_instructors_program_id_fkey"
  add_foreign_key "regencies_cities", "provinces", column: "province_code", primary_key: "code", name: "regencies_cities_province_code_fkey"
  add_foreign_key "students_pkgs", "pkgs", name: "students_pkgs_pkg_id_fkey"
  add_foreign_key "students_pkgs", "students", name: "students_pkgs_student_id_fkey"
  add_foreign_key "students_pkgs_instructors_schedules", "instructors_schedules", name: "students_pkgs_instructors_schedule_instructors_schedule_id_fkey"
  add_foreign_key "students_pkgs_instructors_schedules", "students_pkgs", name: "students_pkgs_instructors_schedules_students_pkg_id_fkey", on_delete: :cascade
  add_foreign_key "students_qualifications", "pkgs", name: "students_qualifications_pkg_id_fkey"
  add_foreign_key "students_qualifications", "students", name: "students_qualifications_student_id_fkey"
  add_foreign_key "students_records", "pkgs", name: "students_records_pkg_id_fkey"
  add_foreign_key "students_records", "students", name: "students_records_student_id_fkey"
  add_foreign_key "users", "groups", name: "users_group_id_fkey"
  add_foreign_key "users_instructors", "instructors", name: "users_instructors_instructor_id_fkey"
  add_foreign_key "users_instructors", "users", name: "users_instructors_user_id_fkey"
end
