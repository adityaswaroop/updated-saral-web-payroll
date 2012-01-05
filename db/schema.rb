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

ActiveRecord::Schema.define(:version => 20111231085709) do

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pt"
    t.boolean  "tds"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
  end

  create_table "default_values", :force => true do |t|
    t.string   "default_type"
    t.string   "value"
    t.integer  "value_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_details", :force => true do |t|
    t.integer  "employee_id"
    t.date     "effective_date"
    t.integer  "salary_group_id"
    t.decimal  "allotted_gross",  :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", :force => true do |t|
    t.string   "empname"
    t.date     "date_of_joining"
    t.date     "date_of_leaving"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "leave_details", :force => true do |t|
    t.integer  "employee_id"
    t.date     "leave_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leave_details", ["employee_id"], :name => "index_leave_details_on_employee_id"

  create_table "lops", :force => true do |t|
    t.integer  "employee_id"
    t.string   "month_year"
    t.float    "lop"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "month_years", :force => true do |t|
    t.integer  "month_year"
    t.integer  "number_of_days"
    t.date     "from_date"
    t.date     "to_date"
    t.string   "month_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salaries", :force => true do |t|
    t.date     "effective_date"
    t.decimal  "salary_amount",      :precision => 8, :scale => 2
    t.integer  "employee_id"
    t.integer  "employee_detail_id"
    t.integer  "salary_head_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "salaries", ["employee_detail_id"], :name => "index_salaries_on_employee_detail_id"
  add_index "salaries", ["employee_id"], :name => "index_salaries_on_employee_id"
  add_index "salaries", ["salary_head_id"], :name => "index_salaries_on_salary_head_id"

  create_table "salary_allotments", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "employee_detail_id"
    t.date     "effective_date"
    t.integer  "salary_head_id"
    t.decimal  "salary_allotment",   :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salary_group_details", :force => true do |t|
    t.string   "calc_type"
    t.string   "calculation"
    t.string   "based_on"
    t.integer  "salary_group_id"
    t.integer  "salary_head_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "salary_group_details", ["salary_group_id"], :name => "index_salary_group_details_on_salary_group_id"
  add_index "salary_group_details", ["salary_head_id"], :name => "index_salary_group_details_on_salary_head_id"

  create_table "salary_groups", :force => true do |t|
    t.string   "salary_group_name"
    t.boolean  "based_on_gross"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salary_heads", :force => true do |t|
    t.string   "head_name"
    t.string   "short_name"
    t.string   "salary_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salary_totals", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "month_year_id"
    t.decimal  "alloted_gross", :precision => 8, :scale => 2
    t.decimal  "earned",        :precision => 8, :scale => 2
    t.decimal  "deducted",      :precision => 8, :scale => 2
    t.decimal  "net_salary",    :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "state_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
