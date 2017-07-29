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

ActiveRecord::Schema.define(version: 20170729083641) do

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
    t.integer  "course_id",                                 null: false
    t.datetime "modified_at", default: "clock_timestamp()", null: false
  end

  add_index "components", ["created_at"], name: "components_created_at", using: :btree

  create_table "courses", force: :cascade do |t|
    t.text    "name",                            null: false
    t.text    "idn_prefix",         default: "", null: false
    t.integer "head_instructor_id"
    t.integer "program_id"
  end

  create_table "districts", force: :cascade do |t|
    t.string "code",              limit: 7,  null: false
    t.string "regency_city_code", limit: 4,  null: false
    t.string "name",              limit: 30, null: false
  end

  add_index "districts", ["code"], name: "districts_code_key", unique: true, using: :btree
  add_index "districts", ["name"], name: "districts_name", using: :btree

  create_table "grades", force: :cascade do |t|
    t.integer  "instructor_id",                                    null: false
    t.integer  "students_record_id",                               null: false
    t.integer  "student_id"
    t.integer  "component_id"
    t.hstore   "score",              default: {},                  null: false
    t.datetime "created_at",         default: "clock_timestamp()", null: false
    t.text     "modified_by"
    t.float    "avg_practice",       default: 0.0,                 null: false
    t.float    "avg_theory",         default: 0.0,                 null: false
    t.datetime "modified_at",        default: "clock_timestamp()", null: false
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

# Could not dump table "pg_aggregate" because of following StandardError
#   Unknown type 'regproc' for column 'aggfnoid'

# Could not dump table "pg_am" because of following StandardError
#   Unknown type 'regproc' for column 'aminsert'

  create_table "pg_amop", id: false, force: :cascade do |t|
    t.integer "amopfamily",               null: false
    t.integer "amoplefttype",             null: false
    t.integer "amoprighttype",            null: false
    t.integer "amopstrategy",   limit: 2, null: false
    t.string  "amoppurpose",              null: false
    t.integer "amopopr",                  null: false
    t.integer "amopmethod",               null: false
    t.integer "amopsortfamily",           null: false
  end

  add_index "pg_amop", ["amopfamily", "amoplefttype", "amoprighttype", "amopstrategy"], name: "pg_amop_fam_strat_index", unique: true, using: :btree
  add_index "pg_amop", ["amopopr", "amoppurpose", "amopfamily"], name: "pg_amop_opr_fam_index", unique: true, using: :btree
  add_index "pg_amop", ["oid"], name: "pg_amop_oid_index", unique: true, using: :btree

# Could not dump table "pg_amproc" because of following StandardError
#   Unknown type 'regproc' for column 'amproc'

# Could not dump table "pg_attrdef" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'adbin'

# Could not dump table "pg_attribute" because of following StandardError
#   Unknown type 'aclitem' for column 'attacl'

  create_table "pg_auth_members", id: false, force: :cascade do |t|
    t.integer "roleid",       null: false
    t.integer "member",       null: false
    t.integer "grantor",      null: false
    t.boolean "admin_option", null: false
  end

  add_index "pg_auth_members", ["member", "roleid"], name: "pg_auth_members_member_role_index", unique: true, using: :btree
  add_index "pg_auth_members", ["roleid", "member"], name: "pg_auth_members_role_member_index", unique: true, using: :btree

  create_table "pg_authid", id: false, force: :cascade do |t|
    t.string   "rolname",        null: false
    t.boolean  "rolsuper",       null: false
    t.boolean  "rolinherit",     null: false
    t.boolean  "rolcreaterole",  null: false
    t.boolean  "rolcreatedb",    null: false
    t.boolean  "rolcanlogin",    null: false
    t.boolean  "rolreplication", null: false
    t.boolean  "rolbypassrls",   null: false
    t.integer  "rolconnlimit",   null: false
    t.text     "rolpassword"
    t.datetime "rolvaliduntil"
  end

  add_index "pg_authid", ["oid"], name: "pg_authid_oid_index", unique: true, using: :btree
  add_index "pg_authid", ["rolname"], name: "pg_authid_rolname_index", unique: true, using: :btree

  create_table "pg_cast", id: false, force: :cascade do |t|
    t.integer "castsource",  null: false
    t.integer "casttarget",  null: false
    t.integer "castfunc",    null: false
    t.string  "castcontext", null: false
    t.string  "castmethod",  null: false
  end

  add_index "pg_cast", ["castsource", "casttarget"], name: "pg_cast_source_target_index", unique: true, using: :btree
  add_index "pg_cast", ["oid"], name: "pg_cast_oid_index", unique: true, using: :btree

# Could not dump table "pg_class" because of following StandardError
#   Unknown type 'xid' for column 'relfrozenxid'

  create_table "pg_collation", id: false, force: :cascade do |t|
    t.string  "collname",      null: false
    t.integer "collnamespace", null: false
    t.integer "collowner",     null: false
    t.integer "collencoding",  null: false
    t.string  "collcollate",   null: false
    t.string  "collctype",     null: false
  end

  add_index "pg_collation", ["collname", "collencoding", "collnamespace"], name: "pg_collation_name_enc_nsp_index", unique: true, using: :btree
  add_index "pg_collation", ["oid"], name: "pg_collation_oid_index", unique: true, using: :btree

# Could not dump table "pg_constraint" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'conbin'

# Could not dump table "pg_conversion" because of following StandardError
#   Unknown type 'regproc' for column 'conproc'

# Could not dump table "pg_database" because of following StandardError
#   Unknown type 'xid' for column 'datfrozenxid'

  create_table "pg_db_role_setting", id: false, force: :cascade do |t|
    t.integer "setdatabase", null: false
    t.integer "setrole",     null: false
    t.text    "setconfig",                array: true
  end

  add_index "pg_db_role_setting", ["setdatabase", "setrole"], name: "pg_db_role_setting_databaseid_rol_index", unique: true, using: :btree

# Could not dump table "pg_default_acl" because of following StandardError
#   Unknown type 'aclitem' for column 'defaclacl'

  create_table "pg_depend", id: false, force: :cascade do |t|
    t.integer "classid",     null: false
    t.integer "objid",       null: false
    t.integer "objsubid",    null: false
    t.integer "refclassid",  null: false
    t.integer "refobjid",    null: false
    t.integer "refobjsubid", null: false
    t.string  "deptype",     null: false
  end

  add_index "pg_depend", ["classid", "objid", "objsubid"], name: "pg_depend_depender_index", using: :btree
  add_index "pg_depend", ["refclassid", "refobjid", "refobjsubid"], name: "pg_depend_reference_index", using: :btree

  create_table "pg_description", id: false, force: :cascade do |t|
    t.integer "objoid",      null: false
    t.integer "classoid",    null: false
    t.integer "objsubid",    null: false
    t.text    "description", null: false
  end

  add_index "pg_description", ["objoid", "classoid", "objsubid"], name: "pg_description_o_c_o_index", unique: true, using: :btree

  create_table "pg_enum", id: false, force: :cascade do |t|
    t.integer "enumtypid",     null: false
    t.float   "enumsortorder", null: false
    t.string  "enumlabel",     null: false
  end

  add_index "pg_enum", ["enumtypid", "enumlabel"], name: "pg_enum_typid_label_index", unique: true, using: :btree
  add_index "pg_enum", ["enumtypid", "enumsortorder"], name: "pg_enum_typid_sortorder_index", unique: true, using: :btree
  add_index "pg_enum", ["oid"], name: "pg_enum_oid_index", unique: true, using: :btree

  create_table "pg_event_trigger", id: false, force: :cascade do |t|
    t.string  "evtname",    null: false
    t.string  "evtevent",   null: false
    t.integer "evtowner",   null: false
    t.integer "evtfoid",    null: false
    t.string  "evtenabled", null: false
    t.text    "evttags",                 array: true
  end

  add_index "pg_event_trigger", ["evtname"], name: "pg_event_trigger_evtname_index", unique: true, using: :btree
  add_index "pg_event_trigger", ["oid"], name: "pg_event_trigger_oid_index", unique: true, using: :btree

  create_table "pg_extension", id: false, force: :cascade do |t|
    t.string  "extname",        null: false
    t.integer "extowner",       null: false
    t.integer "extnamespace",   null: false
    t.boolean "extrelocatable", null: false
    t.text    "extversion",     null: false
    t.integer "extconfig",                   array: true
    t.text    "extcondition",                array: true
  end

  add_index "pg_extension", ["extname"], name: "pg_extension_name_index", unique: true, using: :btree
  add_index "pg_extension", ["oid"], name: "pg_extension_oid_index", unique: true, using: :btree

# Could not dump table "pg_foreign_data_wrapper" because of following StandardError
#   Unknown type 'aclitem' for column 'fdwacl'

# Could not dump table "pg_foreign_server" because of following StandardError
#   Unknown type 'aclitem' for column 'srvacl'

  create_table "pg_foreign_table", id: false, force: :cascade do |t|
    t.integer "ftrelid",   null: false
    t.integer "ftserver",  null: false
    t.text    "ftoptions",              array: true
  end

  add_index "pg_foreign_table", ["ftrelid"], name: "pg_foreign_table_relid_index", unique: true, using: :btree

# Could not dump table "pg_index" because of following StandardError
#   Unknown type 'int2vector' for column 'indkey'

  create_table "pg_inherits", id: false, force: :cascade do |t|
    t.integer "inhrelid",  null: false
    t.integer "inhparent", null: false
    t.integer "inhseqno",  null: false
  end

  add_index "pg_inherits", ["inhparent"], name: "pg_inherits_parent_index", using: :btree
  add_index "pg_inherits", ["inhrelid", "inhseqno"], name: "pg_inherits_relid_seqno_index", unique: true, using: :btree

# Could not dump table "pg_language" because of following StandardError
#   Unknown type 'aclitem' for column 'lanacl'

  create_table "pg_largeobject", id: false, force: :cascade do |t|
    t.integer "loid",   null: false
    t.integer "pageno", null: false
    t.binary  "data",   null: false
  end

  add_index "pg_largeobject", ["loid", "pageno"], name: "pg_largeobject_loid_pn_index", unique: true, using: :btree

# Could not dump table "pg_largeobject_metadata" because of following StandardError
#   Unknown type 'aclitem' for column 'lomacl'

# Could not dump table "pg_namespace" because of following StandardError
#   Unknown type 'aclitem' for column 'nspacl'

  create_table "pg_opclass", id: false, force: :cascade do |t|
    t.integer "opcmethod",    null: false
    t.string  "opcname",      null: false
    t.integer "opcnamespace", null: false
    t.integer "opcowner",     null: false
    t.integer "opcfamily",    null: false
    t.integer "opcintype",    null: false
    t.boolean "opcdefault",   null: false
    t.integer "opckeytype",   null: false
  end

  add_index "pg_opclass", ["oid"], name: "pg_opclass_oid_index", unique: true, using: :btree
  add_index "pg_opclass", ["opcmethod", "opcname", "opcnamespace"], name: "pg_opclass_am_name_nsp_index", unique: true, using: :btree

# Could not dump table "pg_operator" because of following StandardError
#   Unknown type 'regproc' for column 'oprcode'

  create_table "pg_opfamily", id: false, force: :cascade do |t|
    t.integer "opfmethod",    null: false
    t.string  "opfname",      null: false
    t.integer "opfnamespace", null: false
    t.integer "opfowner",     null: false
  end

  add_index "pg_opfamily", ["oid"], name: "pg_opfamily_oid_index", unique: true, using: :btree
  add_index "pg_opfamily", ["opfmethod", "opfname", "opfnamespace"], name: "pg_opfamily_am_name_nsp_index", unique: true, using: :btree

# Could not dump table "pg_pltemplate" because of following StandardError
#   Unknown type 'aclitem' for column 'tmplacl'

# Could not dump table "pg_policy" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'polqual'

# Could not dump table "pg_proc" because of following StandardError
#   Unknown type 'regproc' for column 'protransform'

# Could not dump table "pg_range" because of following StandardError
#   Unknown type 'regproc' for column 'rngcanonical'

  create_table "pg_replication_origin", id: false, force: :cascade do |t|
    t.integer "roident", null: false
    t.text    "roname",  null: false
  end

  add_index "pg_replication_origin", ["roident"], name: "pg_replication_origin_roiident_index", unique: true, using: :btree
  add_index "pg_replication_origin", ["roname"], name: "pg_replication_origin_roname_index", unique: true, using: :btree

# Could not dump table "pg_rewrite" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'ev_qual'

  create_table "pg_seclabel", id: false, force: :cascade do |t|
    t.integer "objoid",   null: false
    t.integer "classoid", null: false
    t.integer "objsubid", null: false
    t.text    "provider", null: false
    t.text    "label",    null: false
  end

  add_index "pg_seclabel", ["objoid", "classoid", "objsubid", "provider"], name: "pg_seclabel_object_index", unique: true, using: :btree

  create_table "pg_shdepend", id: false, force: :cascade do |t|
    t.integer "dbid",       null: false
    t.integer "classid",    null: false
    t.integer "objid",      null: false
    t.integer "objsubid",   null: false
    t.integer "refclassid", null: false
    t.integer "refobjid",   null: false
    t.string  "deptype",    null: false
  end

  add_index "pg_shdepend", ["dbid", "classid", "objid", "objsubid"], name: "pg_shdepend_depender_index", using: :btree
  add_index "pg_shdepend", ["refclassid", "refobjid"], name: "pg_shdepend_reference_index", using: :btree

  create_table "pg_shdescription", id: false, force: :cascade do |t|
    t.integer "objoid",      null: false
    t.integer "classoid",    null: false
    t.text    "description", null: false
  end

  add_index "pg_shdescription", ["objoid", "classoid"], name: "pg_shdescription_o_c_index", unique: true, using: :btree

  create_table "pg_shseclabel", id: false, force: :cascade do |t|
    t.integer "objoid",   null: false
    t.integer "classoid", null: false
    t.text    "provider", null: false
    t.text    "label",    null: false
  end

  add_index "pg_shseclabel", ["objoid", "classoid", "provider"], name: "pg_shseclabel_object_index", unique: true, using: :btree

# Could not dump table "pg_statistic" because of following StandardError
#   Unknown type 'anyarray' for column 'stavalues1'

# Could not dump table "pg_tablespace" because of following StandardError
#   Unknown type 'aclitem' for column 'spcacl'

# Could not dump table "pg_transform" because of following StandardError
#   Unknown type 'regproc' for column 'trffromsql'

# Could not dump table "pg_trigger" because of following StandardError
#   Unknown type 'int2vector' for column 'tgattr'

  create_table "pg_ts_config", id: false, force: :cascade do |t|
    t.string  "cfgname",      null: false
    t.integer "cfgnamespace", null: false
    t.integer "cfgowner",     null: false
    t.integer "cfgparser",    null: false
  end

  add_index "pg_ts_config", ["cfgname", "cfgnamespace"], name: "pg_ts_config_cfgname_index", unique: true, using: :btree
  add_index "pg_ts_config", ["oid"], name: "pg_ts_config_oid_index", unique: true, using: :btree

  create_table "pg_ts_config_map", id: false, force: :cascade do |t|
    t.integer "mapcfg",       null: false
    t.integer "maptokentype", null: false
    t.integer "mapseqno",     null: false
    t.integer "mapdict",      null: false
  end

  add_index "pg_ts_config_map", ["mapcfg", "maptokentype", "mapseqno"], name: "pg_ts_config_map_index", unique: true, using: :btree

  create_table "pg_ts_dict", id: false, force: :cascade do |t|
    t.string  "dictname",       null: false
    t.integer "dictnamespace",  null: false
    t.integer "dictowner",      null: false
    t.integer "dicttemplate",   null: false
    t.text    "dictinitoption"
  end

  add_index "pg_ts_dict", ["dictname", "dictnamespace"], name: "pg_ts_dict_dictname_index", unique: true, using: :btree
  add_index "pg_ts_dict", ["oid"], name: "pg_ts_dict_oid_index", unique: true, using: :btree

# Could not dump table "pg_ts_parser" because of following StandardError
#   Unknown type 'regproc' for column 'prsstart'

# Could not dump table "pg_ts_template" because of following StandardError
#   Unknown type 'regproc' for column 'tmplinit'

# Could not dump table "pg_type" because of following StandardError
#   Unknown type 'regproc' for column 'typinput'

  create_table "pg_user_mapping", id: false, force: :cascade do |t|
    t.integer "umuser",    null: false
    t.integer "umserver",  null: false
    t.text    "umoptions",              array: true
  end

  add_index "pg_user_mapping", ["oid"], name: "pg_user_mapping_oid_index", unique: true, using: :btree
  add_index "pg_user_mapping", ["umuser", "umserver"], name: "pg_user_mapping_user_server_index", unique: true, using: :btree

  create_table "pkgs", force: :cascade do |t|
    t.text    "pkg_old"
    t.integer "level",     null: false
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
  add_foreign_key "courses", "programs", name: "courses_program_id_fkey"
  add_foreign_key "districts", "regencies_cities", column: "regency_city_code", primary_key: "code", name: "districts_regency_city_code_fkey"
  add_foreign_key "grades", "components", name: "grades_component_id_fkey"
  add_foreign_key "grades", "instructors", name: "grades_instructor_id_fkey"
  add_foreign_key "grades", "students", name: "grades_student_id_fkey"
  add_foreign_key "grades", "students_records", name: "grades_students_record_id_fkey"
  add_foreign_key "instructors_schedules", "instructors", name: "instructors_schedules_instructor_id_fkey"
  add_foreign_key "instructors_schedules", "schedules", name: "instructors_schedules_schedule_id_fkey"
  add_foreign_key "pkgs", "courses", name: "pkgs_course_id_fkey"
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
