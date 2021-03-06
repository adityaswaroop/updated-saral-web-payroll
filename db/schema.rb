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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120405084536) do

  create_table "attendance_configurations", :force => true do |t|
    t.string   "attendance"
    t.string   "short_name"
    t.string   "salary_calendar_days"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "branches", :force => true do |t|
    t.string   "branch_name"
    t.string   "responsible_person"
    t.string   "address"
    t.integer  "pf_group_id"
    t.integer  "esi_group_id"
    t.integer  "pt_group_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "esi_applicable"
  end

  add_index "branches", ["esi_group_id"], :name => "index_branches_on_esi_group_id"
  add_index "branches", ["pf_group_id"], :name => "index_branches_on_pf_group_id"
  add_index "branches", ["pt_group_id"], :name => "index_branches_on_pt_group_id"

  create_table "classification_headings", :force => true do |t|
    t.string   "classification_heading_name"
    t.integer  "display_order"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "classifications", :force => true do |t|
    t.integer  "classification_heading_id"
    t.string   "classification_name"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "classifications", ["classification_heading_id"], :name => "index_classifications_on_classification_heading_id"

  create_table "companies", :force => true do |t|
    t.string   "companyname"
    t.string   "responsible_person"
    t.string   "address"
    t.string   "website"
    t.date     "dateofestablishment"
    t.boolean  "pf"
    t.boolean  "esi"
    t.string   "phonenumber1"
    t.string   "phonenumber2"
    t.string   "address2"
    t.string   "address3"
    t.string   "email"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "pt"
    t.boolean  "tds"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
  end

  create_table "employee_details", :force => true do |t|
    t.integer  "employee_id"
    t.date     "effective_date"
    t.integer  "salary_group_id"
    t.decimal  "allotted_gross",              :precision => 8, :scale => 2
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.hstore   "classification"
    t.integer  "branch_id"
    t.integer  "financial_institution_id"
    t.integer  "attendance_configuration_id"
    t.string   "bank_account_number"
    t.date     "effective_to"
    t.string   "pan"
    t.date     "pan_effective_date"
  end

  add_index "employee_details", ["attendance_configuration_id"], :name => "index_employee_details_on_attendance_configuration_id"
  add_index "employee_details", ["branch_id"], :name => "index_employee_details_on_branch_id"
  add_index "employee_details", ["employee_id"], :name => "index_employee_details_on_employee_id"
  add_index "employee_details", ["financial_institution_id"], :name => "index_employee_details_on_financial_institution_id"
  add_index "employee_details", ["salary_group_id"], :name => "index_employee_details_on_salary_group_id"

  create_table "employees", :force => true do |t|
    t.string   "empname"
    t.date     "date_of_joining"
    t.date     "date_of_leaving"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.date     "date_of_birth"
    t.string   "marital_status"
    t.string   "father_name"
    t.string   "spouse_name"
    t.string   "gender"
    t.string   "present_res_no"
    t.string   "present_res_name"
    t.string   "present_street"
    t.string   "present_locality"
    t.string   "present_city"
    t.integer  "present_state_id"
    t.string   "perm_res_no"
    t.string   "perm_res_name"
    t.string   "perm_street"
    t.string   "perm_locality"
    t.string   "perm_city"
    t.integer  "perm_state_id"
    t.boolean  "perm_sameas_present"
    t.string   "email"
    t.string   "mobile"
    t.string   "refno"
    t.boolean  "restrct_pf",          :default => false
  end

  add_index "employees", ["present_state_id"], :name => "index_employees_on_present_state_id"

  create_table "esi_group_rates", :force => true do |t|
    t.integer  "esi_group_id"
    t.float    "employee_rate"
    t.float    "employer_rate"
    t.float    "cut_off"
    t.float    "minimum_limit_dailywage"
    t.string   "round_off"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "esi_group_rates", ["esi_group_id"], :name => "index_esi_group_rates_on_esi_group_id"

  create_table "esi_groups", :force => true do |t|
    t.string   "esi_group_name"
    t.string   "address"
    t.string   "esi_no"
    t.string   "esi_local_office"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "financial_institutions", :force => true do |t|
    t.string   "name"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_line3"
    t.string   "address_line4"
    t.string   "pincode"
    t.string   "branch_code"
    t.string   "email"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "holidays", :force => true do |t|
    t.integer  "attendance_configuration_id"
    t.date     "holiday_date"
    t.string   "description"
    t.boolean  "national_holiday"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "holidays", ["attendance_configuration_id"], :name => "index_holidays_on_attendance_configuration_id"

  create_table "hr_categories", :force => true do |t|
    t.string   "category_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "hr_category_details", :force => true do |t|
    t.integer  "hr_category_id"
    t.string   "name"
    t.string   "data_type"
    t.boolean  "required"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "hr_category_details", ["hr_category_id"], :name => "index_hr_category_details_on_hr_category_id"

  create_table "hr_masters", :force => true do |t|
    t.integer  "hr_category_id"
    t.integer  "employee_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.hstore   "category_values"
  end

  add_index "hr_masters", ["employee_id"], :name => "index_hr_masters_on_employee_id"
  add_index "hr_masters", ["hr_category_id"], :name => "index_hr_masters_on_hr_category_id"

  create_table "leave_details", :force => true do |t|
    t.integer  "employee_id"
    t.date     "leave_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "leave_details", ["employee_id"], :name => "index_leave_details_on_employee_id"

  create_table "paymonths", :force => true do |t|
    t.integer  "month_year"
    t.integer  "number_of_days"
    t.date     "from_date"
    t.date     "to_date"
    t.string   "month_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "pf_group_rates", :force => true do |t|
    t.integer  "pf_group_id"
    t.integer  "paymonth_id"
    t.float    "account_number_21"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.float    "pension_fund"
    t.float    "epf"
    t.float    "account_number_02"
    t.float    "account_number_22"
    t.string   "round_off"
    t.boolean  "restrict_employer_share"
    t.boolean  "restrict_employee_share_to_employer_share"
    t.float    "employer_epf"
    t.float    "cutoff"
    t.date     "effective_date"
  end

  add_index "pf_group_rates", ["paymonth_id"], :name => "index_pf_group_rates_on_paymonth_id"
  add_index "pf_group_rates", ["pf_group_id"], :name => "index_pf_group_rates_on_pf_group_id"

  create_table "pf_groups", :force => true do |t|
    t.string   "pf_group"
    t.string   "pf_number"
    t.string   "db_file_code"
    t.integer  "extension"
    t.string   "address"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "pt_group_rates", :force => true do |t|
    t.integer  "pt_group_id"
    t.integer  "paymonth_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "pt_group_rates", ["paymonth_id"], :name => "index_pt_group_rates_on_paymonth_id"
  add_index "pt_group_rates", ["pt_group_id"], :name => "index_pt_group_rates_on_pt_group_id"

  create_table "pt_groups", :force => true do |t|
    t.string   "name"
    t.integer  "state_id"
    t.string   "certificate_no"
    t.string   "pto_circle_no"
    t.string   "address"
    t.string   "return_period"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "pt_groups", ["state_id"], :name => "index_pt_groups_on_state_id"

  create_table "pt_rates", :force => true do |t|
    t.integer  "pt_group_id"
    t.integer  "paymonth_id"
    t.decimal  "min_sal_range"
    t.decimal  "max_sal_range"
    t.decimal  "pt"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "pt_rates", ["paymonth_id"], :name => "index_pt_rates_on_paymonth_id"
  add_index "pt_rates", ["pt_group_id"], :name => "index_pt_rates_on_pt_group_id"

  create_table "salaries", :force => true do |t|
    t.date     "effective_date"
    t.decimal  "salary_amount",          :precision => 8, :scale => 2
    t.integer  "employee_id"
    t.integer  "employee_detail_id"
    t.integer  "salary_head_id"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "salary_group_detail_id"
  end

  add_index "salaries", ["employee_detail_id"], :name => "index_salaries_on_employee_detail_id"
  add_index "salaries", ["employee_id"], :name => "index_salaries_on_employee_id"
  add_index "salaries", ["salary_group_detail_id"], :name => "index_salaries_on_salary_group_detail_id"
  add_index "salaries", ["salary_head_id"], :name => "index_salaries_on_salary_head_id"

  create_table "salary_allotments", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "employee_detail_id"
    t.date     "effective_date"
    t.integer  "salary_head_id"
    t.decimal  "salary_allotment",       :precision => 8, :scale => 2
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.integer  "salary_group_detail_id"
  end

  add_index "salary_allotments", ["employee_detail_id"], :name => "index_salary_allotments_on_employee_detail_id"
  add_index "salary_allotments", ["employee_id"], :name => "index_salary_allotments_on_employee_id"
  add_index "salary_allotments", ["salary_group_detail_id"], :name => "index_salary_allotments_on_salary_group_detail_id"
  add_index "salary_allotments", ["salary_head_id"], :name => "index_salary_allotments_on_salary_head_id"

  create_table "salary_group_details", :force => true do |t|
    t.string   "calc_type"
    t.string   "calculation"
    t.string   "based_on"
    t.integer  "salary_group_id"
    t.integer  "salary_head_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.boolean  "pf_applicability"
    t.decimal  "pf_percentage"
    t.string   "print_name"
    t.integer  "print_order"
  end

  add_index "salary_group_details", ["salary_group_id"], :name => "index_salary_group_details_on_salary_group_id"
  add_index "salary_group_details", ["salary_head_id"], :name => "index_salary_group_details_on_salary_head_id"

  create_table "salary_groups", :force => true do |t|
    t.string   "salary_group_name"
    t.boolean  "based_on_gross"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "salary_heads", :force => true do |t|
    t.string   "head_name"
    t.string   "short_name"
    t.string   "salary_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "states", :force => true do |t|
    t.string   "state_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_foreign_key "branches", "esi_groups", :name => "branches_esi_group_id_fk"
  add_foreign_key "branches", "pf_groups", :name => "branches_pf_group_id_fk"
  add_foreign_key "branches", "pt_groups", :name => "branches_pt_group_id_fk"

  add_foreign_key "employee_details", "attendance_configurations", :name => "employee_details_attendance_configuration_id_fk"
  add_foreign_key "employee_details", "branches", :name => "employee_details_branch_id_fk"
  add_foreign_key "employee_details", "financial_institutions", :name => "employee_details_financial_institution_id_fk"

  add_foreign_key "esi_group_rates", "esi_groups", :name => "esi_group_rates_esi_group_id_fk"

  add_foreign_key "holidays", "attendance_configurations", :name => "holidays_attendance_configuration_id_fk"

  add_foreign_key "hr_category_details", "hr_categories", :name => "hr_category_details_hr_category_id_fk"

  add_foreign_key "hr_masters", "employees", :name => "hr_masters_employee_id_fk"
  add_foreign_key "hr_masters", "hr_categories", :name => "hr_masters_hr_category_id_fk"

  add_foreign_key "pf_group_rates", "paymonths", :name => "pf_group_rates_paymonth_id_fk"
  add_foreign_key "pf_group_rates", "pf_groups", :name => "pf_group_rates_pf_group_id_fk"

  add_foreign_key "pt_group_rates", "paymonths", :name => "pt_group_rates_paymonth_id_fk"
  add_foreign_key "pt_group_rates", "pt_groups", :name => "pt_group_rates_pt_group_id_fk"

  add_foreign_key "pt_rates", "pt_groups", :name => "pt_rates_pt_group_id_fk"

  add_foreign_key "salaries", "salary_group_details", :name => "salaries_salary_group_detail_id_fk"

  add_foreign_key "salary_allotments", "salary_group_details", :name => "salary_allotments_salary_group_detail_id_fk"

end
