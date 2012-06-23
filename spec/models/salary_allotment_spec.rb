require 'spec_helper'

describe SalaryAllotment do
  it { should belong_to(:salary_head)}

  it { should belong_to(:employee)}

  it { should belong_to(:employee_detail)}

  it { should belong_to(:salary_group_detail)}

  it "should return allotted salaries" do
    salary_head = FactoryGirl.create(:salary_head)
    salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
    sal_allot = FactoryGirl.create(:salary_allotment, :salary_group_detail_id => salary_group_detail.id,:salary_head_id=>salary_head.id)
    SalaryAllotment.get_allotted_salaries("Feb/2011",sal_allot.employee_id).should be_true
  end

  it "should return allotted salaries for previous effective date" do
    salary_head = FactoryGirl.create(:salary_head)
    salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
    sal_allot = FactoryGirl.create(:salary_allotment, :salary_group_detail_id => salary_group_detail.id,:salary_head_id=>salary_head.id)
    SalaryAllotment.get_allotted_salaries_for_max_effective_date("Feb/2011", sal_allot.employee_id).should be_true
  end

  describe "get row for salary_allotment" do
    it "give allotted salary for same pay month in which salary is allotted" do
      employee = FactoryGirl.create(:employee)
      salary_head = FactoryGirl.create(:salary_head)
      salary_group = FactoryGirl.create(:salary_group)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_group_id=>salary_group.id,:salary_head_id=>salary_head.id)
      attendance_configuration = FactoryGirl.create(:attendance_configuration)
      financial_institution = FactoryGirl.create(:financial_institution)
      branch = FactoryGirl.create(:branch)
      employee_detail = FactoryGirl.create(:employee_detail,:salary_group_id=>salary_group.id,:branch_id=>branch.id,:attendance_configuration_id=>attendance_configuration.id,:financial_institution_id=>financial_institution.id)
      salary_allotment = FactoryGirl.create(:salary_allotment,:employee_id=>employee.id,:employee_detail_id=>employee_detail.id,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id)
      sal_allot = SalaryAllotment.row_for_salary_allotment employee.id, "Earnings", "Feb/2011"
      sal_allot.should eq([salary_allotment])
    end

    it "give allotted salary wrt max effective date for different pay month in which salary is not allotted" do
      employee = FactoryGirl.create(:employee)
      salary_head = FactoryGirl.create(:salary_head)
      salary_group = FactoryGirl.create(:salary_group)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_group_id=>salary_group.id,:salary_head_id=>salary_head.id)
      attendance_configuration = FactoryGirl.create(:attendance_configuration)
      financial_institution = FactoryGirl.create(:financial_institution)
      branch = FactoryGirl.create(:branch)
      employee_detail = FactoryGirl.create(:employee_detail,:salary_group_id=>salary_group.id,:branch_id=>branch.id,:attendance_configuration_id=>attendance_configuration.id,:financial_institution_id=>financial_institution.id)
      salary_allotment = FactoryGirl.create(:salary_allotment,:employee_id=>employee.id,:employee_detail_id=>employee_detail.id,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id)
      sal_allot = SalaryAllotment.row_for_salary_allotment employee.id, "Earnings", "Mar/2011"
      sal_allot.should eq([salary_allotment])
    end

    it "give allotted salary for different pay month in which salary is not allotted and it is also not max effective date" do
      employee = FactoryGirl.create(:employee)
      salary_head = FactoryGirl.create(:salary_head)
      salary_group = FactoryGirl.create(:salary_group)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_group_id=>salary_group.id,:salary_head_id=>salary_head.id)
      attendance_configuration = FactoryGirl.create(:attendance_configuration)
      financial_institution = FactoryGirl.create(:financial_institution)
      branch = FactoryGirl.create(:branch)
      employee_detail = FactoryGirl.create(:employee_detail,:salary_group_id=>salary_group.id,:branch_id=>branch.id,:attendance_configuration_id=>attendance_configuration.id,:financial_institution_id=>financial_institution.id)
      salary_allotment1 = FactoryGirl.create(:salary_allotment,:employee_id=>employee.id,:employee_detail_id=>employee_detail.id,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id)
      salary_allotment2 = FactoryGirl.create(:salary_allotment,:employee_id=>employee.id,:employee_detail_id=>employee_detail.id,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id,:effective_date=>'2011-05-01')
      sal_allot = SalaryAllotment.row_for_salary_allotment employee.id, "Earnings", "Apr/2011"
      sal_allot.should eq([salary_allotment1])
    end
  end

  describe "generation of formula" do
    before :each do
      @salHeadBasic = FactoryGirl.create(:salary_head)
      @salHeadDA = FactoryGirl.create(:salary_head, head_name: "DA",short_name: "DA", salary_type: "Earnings")
      @salHeadHRA = FactoryGirl.create(:salary_head, head_name: "HRA",short_name: "HRA", salary_type: "Earnings")

      @salaryGrp = FactoryGirl.create(:salary_group, based_on_gross: true)
      @paymonth = FactoryGirl.create(:paymonth)
      @salaryGrpDetBasic = FactoryGirl.create(:salary_group_detail, salary_group_id: @salaryGrp.id, salary_head_id: @salHeadBasic.id, calc_type: "Formula", calculation: "GROSS * 40/100")
      @salaryGrpDetHRA = FactoryGirl.create(:salary_group_detail, salary_group_id: @salaryGrp.id, salary_head_id: @salHeadHRA.id, calc_type: "Formula", calculation: "(BASIC + DA) * 30/100")
      @attendance_configuration = FactoryGirl.create(:attendance_configuration)
      @branch = FactoryGirl.create(:branch)
      @financial_institution = FactoryGirl.create(:financial_institution)
    end

    it "should give nested formula" do
      salaryGrpDetDA = FactoryGirl.create(:salary_group_detail, salary_group_id: @salaryGrp.id, salary_head_id: @salHeadDA.id, calc_type: "Formula", calculation: "GROSS * 20/100")
      employee = FactoryGirl.create(:employee)
      employee_detail = FactoryGirl.create(:employee_detail, salary_group_id: @salaryGrp.id,:branch_id => @branch.id,:financial_institution_id => @financial_institution.id,:attendance_configuration_id => @attendance_configuration.id)
      sal_allotHRA = FactoryGirl.create(:salary_allotment, :salary_group_detail_id => @salaryGrpDetHRA.id, salary_head_id: @salHeadHRA.id, employee_detail_id: employee_detail.id)
      formula = sal_allotHRA.generation_formula
      formula.should eq("( (GROSS * 40/100) + (GROSS * 20/100) ) * 30/100")
    end

    it "should give 0 value in nested formula if calc_type of salary head is not formula" do
      salaryGrpDetDA = FactoryGirl.create(:salary_group_detail, salary_group_id: @salaryGrp.id, salary_head_id: @salHeadDA.id, calc_type: "Lumpsum", calculation: "")
      employee = FactoryGirl.create(:employee)
      employee_detail = FactoryGirl.create(:employee_detail, salary_group_id: @salaryGrp.id,:branch_id => @branch.id,:financial_institution_id => @financial_institution.id,:attendance_configuration_id => @attendance_configuration.id)
      sal_allotHRA = FactoryGirl.create(:salary_allotment, :salary_group_detail_id => @salaryGrpDetHRA.id, salary_head_id: @salHeadHRA.id, employee_detail_id: employee_detail.id)
      formula = sal_allotHRA.generation_formula
      formula.should eq("( (GROSS * 40/100) + 0 ) * 30/100")
    end

  end

end