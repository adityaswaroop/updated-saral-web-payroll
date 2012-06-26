require 'spec_helper'

describe Employee do
  before(:each) do

    @attr = {
      :empname => "GaneshL",
      :date_of_birth => "1985-1-1",
      :date_of_joining => "2009-10-31",
      :date_of_leaving => "2010-11-30",
      :present_state_id => "1",
      :refno => "A1",
      :email => "gane@gane.com",
      :leaving_reason => "Without Reason"
    }
  end

  it { should have_many(:leave_details)}

  it { should have_many(:employee_details)}

  it { should have_many(:salary_allotments)}

  it { should have_one(:employee_statutory)}

  it { should have_many(:pf_calculated_values)}

  it { should have_many(:esi_calculated_values)}

  it { should have_many(:hr_masters)}

  it { should have_many(:leave_takens)}

  it { should have_many(:every_month_comp_values)}

  it "should require a name" do
    no_name_employee = Employee.new(@attr.merge(:empname => ""))
    no_name_employee.should_not be_valid
  end

  it "should not accept names that are too long" do
    long_name = "s" * 101
    long_name_employee = Employee.new(@attr.merge(:empname => long_name))
    long_name_employee.should_not be_valid
  end

  it "should require dateofjoining" do
    no_date_employee = Employee.new(@attr.merge(:date_of_joining => ""))
    no_date_employee.should_not be_valid
  end

  it "rejects duplicate Ref nos" do
    Employee.create!(@attr)
    emp_with_duplicate_refno = Employee.new(@attr)
    emp_with_duplicate_refno.should_not be_valid
  end

  it "rejects Ref nos identical up to case" do
    upcased_refno = @attr[:refno].upcase
    Employee.create!(@attr.merge(:refno => upcased_refno))
    emp_with_duplicate_refno = Employee.new(@attr)
    emp_with_duplicate_refno.should_not be_valid
  end

    it "accepts valid email addresses" do
    emails = %w[emp@abc.com THE_EMP@abc.b.org first.last@sdf.jp]
    emails.each do |email|
      valid_email_emp = Employee.new(@attr.merge(:email => email))
      valid_email_emp.should be_valid
    end
  end

  it "rejects invalid email addresses" do
    emails = %w[emp@abc,com emp_at_rel.org example.emp@gan.]
    emails.each do |email|
    invalid_email_emp = Employee.new(@attr.merge(:email => email))
    invalid_email_emp.should_not be_valid
    end
  end

  it "rejects duplicate email addresses" do
    Employee.create!(@attr)
    emp_with_duplicate_email = Employee.new(@attr)
    emp_with_duplicate_email.should_not be_valid
  end

  it "rejects email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    Employee.create!(@attr.merge(:email => upcased_email))
    emp_with_duplicate_email = Employee.new(@attr)
    emp_with_duplicate_email.should_not be_valid
  end

  it "requires a state" do
    no_state_employee = Employee.new(@attr.merge(:present_state_id => ""))
    no_state_employee.should_not be_valid
  end


  describe "dateofjoining" do
    it "should be before dateofleaving if dateofleaving exists" do
      wrongdoj_employee = Employee.new(@attr.merge(:date_of_joining => "2010-12-01"))
      wrongdoj_employee.should_not be_valid
    end
  end

  describe "dateofbirth" do
    it "should be before dateofjoining" do
      wrongdob_employee = Employee.new(@attr.merge(:date_of_birth => "2009-11-01"))
      wrongdob_employee.should_not be_valid
    end
  end


  it "should return employee whose salary is not allotted" do
    salary_head = FactoryGirl.create(:salary_head)
    salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
    sal_allot = FactoryGirl.create(:salary_allotment,:salary_allotment=>0, :salary_group_detail_id => salary_group_detail.id,:salary_head_id=>salary_head.id)
    Employee.employee_with_salary_not_allotted.should be_true
  end

  it "should return employee whose salary is allotted" do
    salary_head = FactoryGirl.create(:salary_head)
    salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
    sal_allot = FactoryGirl.create(:salary_allotment, :salary_group_detail_id => salary_group_detail.id,:salary_head_id=>salary_head.id)
    Employee.employee_with_salary_allotted.should be_true
  end

  it "checks for the DOJ validation with probation complete date given for the employee" do
    employee = Employee.new(:empname => "Rahul",:date_of_joining => "2009-10-31",:present_state_id => "1",:refno => "A1",:email => "gane@gane.com", :date_of_birth => "1986-01-01",:probation_complete_date => "2009-10-23")
    employee.save
    employee.errors.messages[:probation_complete_date].should eq(["probation complete date should be after date of joining"])
  end

  it "checks for the DOJ validation with confirmation date given for the employee" do
    employee = Employee.new(:empname => "Rahul",:date_of_joining => "2009-10-31",:present_state_id => "1",:refno => "A1",:email => "gane@gane.com", :date_of_birth => "1986-01-01",:confirmation_date => "2009-10-23")
    employee.save
    employee.errors.messages[:confirmation_date].should eq(["confirmation date should be after date of joining"])
  end

  it "checks for the DOJ validation with salary start date given for the employee" do
    employee = Employee.new(:empname => "Rahul",:date_of_joining => "2009-10-31",:present_state_id => "1",:refno => "A1",:email => "gane@gane.com", :date_of_birth => "1986-01-01",:salary_start_date => "2009-10-23")
    employee.save
    employee.errors.messages[:salary_start_date].should eq([" should be after date of joining"])
  end

  it "checks for the DOJ validation with retirement date given for the employee" do
    employee = Employee.new(:empname => "Rahul",:date_of_joining => "2009-10-31",:present_state_id => "1",:refno => "A1",:email => "gane@gane.com", :date_of_birth => "1986-01-01",:retirement_date => "2009-10-23")
    employee.save
    employee.errors.messages[:retirement_date].should eq(["retirement date should be after date of joining"])
  end

  it "should concatenate employee name and ref numbere and return" do
    employee = FactoryGirl.create(:employee)
    value = employee.empname+'('+employee.refno.to_s+')'
    employee.empname_and_refno.should eq(value)
  end

  describe "should return employee list" do
    it "should return employee list whose DOL is null and DOJ is before the selected pay month" do
      paymonth = FactoryGirl.create(:paymonth,:month_name => 'Jan/2012')
      employee = FactoryGirl.create(:employee)
      employee_list = Employee.employee_list paymonth.month_name
      employee_list.count.should eq(1)
    end

    it "should return employee list whose DOL is in same month and DOJ is before the selected pay month" do
      paymonth = FactoryGirl.create(:paymonth,:month_name => 'Jan/2012')
      employee = FactoryGirl.create(:employee,:date_of_leaving=>'2012-01-25',:leaving_reason=>'No Reason')
      employee_list = Employee.employee_list paymonth.month_name
      employee_list.count.should eq(1)
    end

  end


end
