FactoryGirl.define do
  factory :employee do
    id 1
    refno 1001
    email "aditya.swaroop@relyonsoft.com"
    present_state_id "1"
    empname "XYZ"
    date_of_joining "2011-02-01"
    date_of_leaving ""
    restrct_pf false
    leaving_reason ""
  end

  factory :company do
    companyname "Relyon"
    responsible_person "Aditya"
    address "123 Street"
    email "info@relyon.com"
    dateofestablishment "2011-01-01"
  end

  factory :lop do
    employee
    month_year "Jan/2011"
    lop 1
  end

  factory :salary_head do
    head_name "Basic"
    short_name "BASIC"
    salary_type "Earnings"
  end

  factory :salary_group do
    salary_group_name "Manager"
    based_on_gross false
  end

 factory :salary_allotment do
    employee_id 1
    employee_detail_id 1
    effective_date '2011-02-01'
    salary_head
    salary_allotment 1000.00
    salary_group_detail_id 1
  end

  factory :salary do
    effective_date '2011-02-01'
    salary_amount 1000.00
    actual_salary_amount 1000.00
    employee_id 1
    employee_detail_id 1
    salary_head
    salary_group_detail
  end

  factory :salary_group_detail do
    salary_group_id 1
    salary_head
    calc_type 'Lumpsum'
    calculation ""
    based_on "Pay Days"
    pf_applicability true
    esi_applicability true
    pt_applicability true
    effective_month "Feb/2011"
    calc_priority_no 1
  end

  factory :employee_detail do
    employee_id  1
    effective_date "2011-02-10"
    salary_group_id 1
    allotted_gross 5000
    classification {'Department => development'}
    branch_id 1
    financial_institution_id  1
    attendance_configuration_id  2
    bank_account_number 2316
    effective_to  ''

  end

  factory :state do
    state_name "Karnataka"
  end

  factory :leave_definition do
    id 1
    leave_name "Sick Leave"
    short_name "SL"
  end

  factory :leave_detail do
    employee
    leave_date '2011-01-01'
    leave_definition_id 1
  end

 factory :paymonth do
    month_year 24132
    number_of_days 31
    from_date "2010-12-01"
    to_date "2010-12-31"
    month_name  "Dec/2010"
    default_month false
    month_locked false
  end

  factory :pf_esi_rate do
    paymonth
    pf_rate 12.03
    pf_cutoff 1522
    esi_employee_rate 12.03
    esi_employer_rate 6.03
    esi_cutoff 1500
  end

  factory :pt_group do
    name "Group"
    certificate_no "123456"
    pto_circle_no "123456"
    address "Bangalore"
    return_period "Monthly"
    state_id 1
  end

  factory :pt_group_rate do
    pt_group
    paymonth
  end

  factory :pt_rate do
    pt_group
    paymonth
    min_sal_range 0.0
    max_sal_range 5000.0
    pt 100.0
  end


  factory :classification_heading do
    classification_heading_name "Department"
    display_order 1
  end

  factory :classification do
    classification_heading_id 1
    classification_name "WDO"
  end

  factory :attendance_configuration do
    id 2
    attendance "Karnataka"
    short_name "KARNATAKA"
    salary_calendar_days "Actual Days / Month"
  end

  factory :holiday do
    attendance_configuration
    holiday_date "2012-01-26"
    description "Republic Day"
    national_holiday true

  end

  factory :pf_group do
    pf_group "Kar"
    pf_number "ka1201"
    db_file_code "10210"
    extension 1
    address "bangalore"
  end

  factory :esi_group do
    esi_group_name "Karnataka"
    address "12 Street"
    esi_no "3432VD"
    esi_local_office "Bangalore"
  end

  factory :financial_institution do
    id 2
    name "State Bank of India"
    address_line1 "123 Street"
    address_line2 "Mahalakshmipuram"
    address_line3 "West of Chord Road"
    address_line4 "Bangalore,Karnataka"
    pincode "560086"
    branch_code "SBI000434"
    email "sbi@gmail.com"
  end

  factory :branch do
    id 1
    branch_name "Bangalore"
    responsible_person "rahul"
    address "Bangalore"
    esi_applicable false
  end

  factory :hr_category do
    category_name "Family"
  end

  factory :hr_category_detail do
    hr_category
    name "Name"
    data_type "String"
    required true
  end

  factory :hr_master do
    hr_category
    employee
    category_values {'1=>Kanaily'}
  end

  factory :pf_group_rate do
    pf_group
    paymonth
    account_number_21 2
    pension_fund 2
    epf 12
    account_number_02 3
    account_number_22 4
    round_off "Higher Rupees"
    restrict_employer_share false
    restrict_employee_share_to_employer_share false
    employer_epf 3
    cutoff 6500
    effective_date '2010-12-01'
  end

  factory :esi_group_rate do
    esi_group
    employee_rate 1.75
    employer_rate 4.75
    cut_off 15000
    minimum_limit_dailywage 100
    round_off "Higher Rupees"
  end

  factory :pf_detail do
    branch
    pf_group
    pf_effective_date "2012-01-01"
  end

  factory :esi_detail do
    branch
    esi_group
    esi_effective_date "2012-01-01"
  end

  factory :pt_detail do
    branch
    pt_group
    pt_effective_date "2012-01-01"
  end

  factory :employee_statutory do
    employee
    pan 'aaaaa1234a'
    pan_effective_date '2012-01-01'
    pf_number '1234'
    pf_effective_date '2012-01-01'
    esi_number 'a1234'
    esi_effective_date '2012-01-01'
    zero_pt true
    zero_pension true
    vol_pf true
    vol_pf_percentage 20
    vol_pf_amount 3000
  end

  factory :pf_calculated_value do
    pf_earning 6500.0
    pf_amount 780.0
    epf_amount 540.0
    eps_amount 230.0
    vol_pf_amount 3000.0
    employee
    effective_date "2011-02-01"
  end

  factory :upload_file_type do
    max_file_size 2
    file_type "application/pdf,application/msword"
  end

  factory :company_document do
    company
    remarks "Test"
  end


  factory :leave_opening_balance do
    employee
    leave_definition
    opening_balance 2
  end

  factory :country do
    name "India"
    currency "Indian Rupee"
  end

  factory :leave_taken do
    employee_id 1
    leave_detail_date 'Jan/2012'
    leave_count 2
    lop_count 2
  end

  factory :custom_setting_value do
    group "ESI Rate"
    group_column "employee_rate"
    group_column_value "1.75"
  end

  factory :pt_slab do
    state_id 18
    minimum_sal_range 1200
    pt 120
  end
  factory :date_format do
    date_format "Y-m-d"
    date_format_value "%Y-%m-%d"
  end

  factory :option_setting do
    country_id "120"
    time_zone "(GMT+05:30) Kolkata"
    currency "Rupee"
    salary_calc "Jan/2012"
    date_format "Y-m-d"
  end

end
