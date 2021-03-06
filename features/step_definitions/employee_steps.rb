Given /^User have Employee (.*?) created$/ do |employee|
  @employee=FactoryGirl.create(:employee,:present_state_id=>@state.id)
end

Given /^valid Employee Statutory Details Created$/ do
  EmployeeStatutory.create(employee_id: @employee.id, pan: "aaaaa1234a", pan_effective_date: "2012-05-08", pf_number: "123", pf_effective_date: "2012-05-08", esi_number: "123", esi_effective_date: "2012-05-08", created_at: "2012-05-17 10:31:56", updated_at: "2012-05-17 10:31:56", zero_pt: false, zero_pension: false, vol_pf: false, vol_pf_percentage: nil, vol_pf_amount: nil)
end

Given /^Employee Statutory Details with esi eff. date (.*?) under employee (.*?) created$/ do |date,emp|
  employee=Employee.create(:empname=> emp, :date_of_joining=> "2004-04-04", :date_of_leaving=> nil, :date_of_birth=> "1980-04-01", :marital_status=>"Single", father_name: "xyz", spouse_name: "", gender: "Male", present_res_no: "", present_res_name: "", present_street: "#411, 3rd main, 2nd stage, 9th", present_locality: "", present_city: "Bangalore", present_state_id: @state.id, perm_res_no: nil, perm_res_name: nil, perm_street: nil, perm_locality: nil, perm_city: nil, perm_state_id: nil, perm_sameas_present: nil, email: "shivugowda84@gmail.com", mobile: "919986928734", refno: "V2040402", designation_id: 30, department_id: 1, grade_id: 4, branch_id: 1, financial_institution_id: 1, bank_account_number: "08751050014908", restrct_pf: false, probation_period: nil, probation_complete_date: nil, confirmation_date: nil, salary_start_date: nil, retirement_date: nil, handicapped: nil, emergency_contact_number: nil, official_mail_id: nil, leaving_reason: nil)
  EmployeeStatutory.create(employee_id: employee.id, pan: "aaaaa1234a", pan_effective_date: "2012-05-08", pf_number: "123", pf_effective_date: date, esi_number: "123", esi_effective_date: "2012-05-08", created_at: "2012-05-17 10:31:56", updated_at: "2012-05-17 10:31:56", zero_pt: false, zero_pension: false, vol_pf: false, vol_pf_percentage: nil, vol_pf_amount: nil)
end


Given /^User have required details created$/ do
  FactoryGirl.create(:branch)
  FactoryGirl.create(:financial_institution)
  FactoryGirl.create(:attendance_configuration)
  FactoryGirl.create(:salary_group)
  classification_heading=FactoryGirl.create(:classification_heading)
  FactoryGirl.create(:classification,:classification_heading_id=> classification_heading.id)
end

Given /^employee detail salary group (.*?) created under employee (.*?)$/ do |sal_grp,employee|
  branch=FactoryGirl.create(:branch)
  bank=FactoryGirl.create(:financial_institution)
  atten_config=FactoryGirl.create(:attendance_configuration)
  sal_grp=FactoryGirl.create(:salary_group)
  classification_heading=FactoryGirl.create(:classification_heading)
  FactoryGirl.create(:classification,:classification_heading_id=> classification_heading.id)
  emp=Employee.create(:empname=> employee, :date_of_joining=> "2004-04-04", :date_of_leaving=> nil, :date_of_birth=> "1980-04-01", :marital_status=>"Single", father_name: "xyz", spouse_name: "", gender: "Male", present_res_no: "", present_res_name: "", present_street: "#411, 3rd main, 2nd stage, 9th", present_locality: "", present_city: "Bangalore", present_state_id: @state.id, perm_res_no: nil, perm_res_name: nil, perm_street: nil, perm_locality: nil, perm_city: nil, perm_state_id: nil, perm_sameas_present: nil, email: "shivugowda84@gmail.com", mobile: "919986928734", refno: "V2040402", designation_id: 30, department_id: 1, grade_id: 4, branch_id: 1, financial_institution_id: 1, bank_account_number: "08751050014908", restrct_pf: false, probation_period: nil, probation_complete_date: nil, confirmation_date: nil, salary_start_date: nil, retirement_date: nil, handicapped: nil, emergency_contact_number: nil, official_mail_id: nil, leaving_reason: nil)

  EmployeeDetail.create(employee_id: emp.id, effective_date: "2012-04-03", salary_group_id: sal_grp.id, allotted_gross: 20000, classification: {"Designation"=>"Developer"}, branch_id: branch.id, financial_institution_id: bank.id, attendance_configuration_id: atten_config.id, bank_account_number: "", effective_to: nil, pan: "PAN Applied", pan_effective_date: nil, international_worker: nil)
end

When /^User upload the employees excel file$/ do
  visit path_to("employees_upload")
  attach_file("excel_file", File.join(Rails.root.to_s, 'spec', 'factories', 'Employee_Test.xls'))
end

Then /^User should redirect to employees index page$/ do
  visit path_to("employees")
end

Then /^User should redirect to generate_sample_excel_template$/ do
  visit path_to("employees excel sample")
end

Then /^Employee count should increase by (\d+)$/ do |count|
  Employee.count.should == count.to_i
end

Then /^Employee "(.*?)" should be deleted$/ do |employee|
  Employee.delete(employee)
end
