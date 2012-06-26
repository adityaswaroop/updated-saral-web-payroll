require 'spec_helper'

describe Salary do
   it { should belong_to(:salary_head)}

  it { should belong_to(:employee_detail)}

  describe "Salary Calculation" do

    describe "salary generation" do
      before(:each) do
        @salary_head = FactoryGirl.create(:salary_head)
        @salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
      end
      it "should return true (salary is generated for given employee for given month)" do
        salary = FactoryGirl.create(:salary, :salary_head_id => @salary_head.id, :salary_group_detail_id => @salary_group_detail.id)
        Salary.is_salary_generated?("Feb/2011", salary.employee_id).should be_true
      end

      it "should get salary on basis of salary type" do
        salary = FactoryGirl.create(:salary, :salary_head_id => @salary_head.id, :salary_group_detail_id => @salary_group_detail.id)
        getSalary = Salary.get_salary_on_salary_type salary.salary_head.salary_type, 'Feb/2011', salary.employee_id.to_s
        getSalary[0].salary_amount.should eq(1000.00)
        getSalary[0].salary_head.head_name.should eq("Basic")
      end
    end

    describe "calculate salary" do
      before :each do
        @salary_head = FactoryGirl.create(:salary_head)
        @attendance_configuration = FactoryGirl.create(:attendance_configuration)
        @financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        @pay_month =  FactoryGirl.create(:paymonth, :month_year => 24134, :number_of_days => 28,:from_date => "2011-02-01",:to_date => "2011-02-28",:month_name => "Feb/2011")
        esi_group = FactoryGirl.create(:esi_group)
        @branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id, :esi_group_id => esi_group.id)

        pf_group_rate = FactoryGirl.create(:pf_group_rate,:pf_group_id => pf_group.id, :paymonth_id => @pay_month.id)
        esi_group_rate = FactoryGirl.create(:esi_group_rate,:esi_group_id => esi_group.id, :paymonth_id => @pay_month.id)
      end

      it "should give no of present days" do
        employee = FactoryGirl.create(:employee)
        leave_definition = FactoryGirl.create(:leave_definition)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => @attendance_configuration.id,:branch_id => @branch.id, :financial_institution_id => @financial_institution.id)
        leave_detail = FactoryGirl.create(:leave_detail,:leave_date => "2011-02-02", :employee_id => employee.id,:leave_definition_id=>leave_definition.id)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
        salary_allotment = FactoryGirl.create(:salary_allotment,:salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id,:employee_id => employee.id,:employee_detail_id => employee_detail.id)
        salary = FactoryGirl.create(:salary,:employee_id => employee.id, :salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id, :present_days=>24, :pay_days=>28)
        salary_send = {"0"=>[salary]}
        get_leave_count = Salary.calculate_salary salary_send,"Feb/2011"
        no_of_present_days = get_leave_count["0"][0][:present_days]
        no_of_present_days.should eq(24)
      end

      it "should give no of present days if salary_allotment is not there" do
        employee = FactoryGirl.create(:employee)
        leave_definition = FactoryGirl.create(:leave_definition)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => @attendance_configuration.id,:branch_id => @branch.id, :financial_institution_id => @financial_institution.id)
        leave_detail = FactoryGirl.create(:leave_detail,:leave_date => "2011-02-02", :employee_id => employee.id,:leave_definition_id=>leave_definition.id)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
        salary = FactoryGirl.create(:salary,:employee_id => employee.id, :salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id, :present_days=>24, :pay_days=>28)
        salary_send = {"0"=>[salary]}
        get_leave_count = Salary.calculate_salary salary_send,"Feb/2011"
        no_of_present_days = get_leave_count["0"][0][:present_days]
        no_of_present_days.should eq(24)
      end
    end

    describe "Save Every Month Component value" do
      it "should save every month component value for salary and paymonth" do
        salary_head = FactoryGirl.create(:salary_head)
        salary_group = FactoryGirl.create(:salary_group)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id, :esi_group_id => esi_group.id)
        paymonth = FactoryGirl.create(:paymonth,:month_year=>24134,:number_of_days=>31,:from_date=> "2011-02-01",:to_date=>"2011-02-28",:month_name=>"Feb/2011")
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:employee_id=>employee.id,:salary_group_id=>salary_group.id,:attendance_configuration_id=>attendance_configuration.id,:branch_id=>branch.id, :financial_institution_id=>financial_institution.id)
        salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_group_id=>salary_group.id,:salary_head_id => salary_head.id,:calc_type=>"Every Month")
        salary = FactoryGirl.create(:salary,:employee_id => employee.id,:employee_detail_id=>employee_detail.id,:salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id, :present_days=>24, :pay_days=>28)
        salary_send = {"0"=>[salary]}
        salary_save = Salary.save_component_value salary_send, paymonth.month_name
        salary_save.count.should eq(1)
      end

      it "should update every month component value for salary and paymonth" do
        salary_head = FactoryGirl.create(:salary_head)
        salary_group = FactoryGirl.create(:salary_group)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id, :esi_group_id => esi_group.id)
        paymonth = FactoryGirl.create(:paymonth,:month_year=>24134,:number_of_days=>31,:from_date=> "2011-02-01",:to_date=>"2011-02-28",:month_name=>"Feb/2011")
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:employee_id=>employee.id,:salary_group_id=>salary_group.id,:attendance_configuration_id=>attendance_configuration.id,:branch_id=>branch.id, :financial_institution_id=>financial_institution.id)
        salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_group_id=>salary_group.id,:salary_head_id => salary_head.id,:calc_type=>"Every Month")
        every_month_comp_value = EveryMonthCompValue.create(:paymonth_id=>paymonth.id,:employee_id=>employee.id,:salary_group_id=>salary_group.id,:salary_amount=>{salary_head.id=>1000})
        salary = FactoryGirl.create(:salary,:employee_id => employee.id,:employee_detail_id=>employee_detail.id,:salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id, :present_days=>24, :pay_days=>28)
        salary_send = {"0"=>[salary]}
        salary_save = Salary.save_component_value salary_send, paymonth.month_name
        salary_save.should be_true
      end
    end

    describe "find salary calculation days" do
      it "should give pay days as 28" do
        salary_head = FactoryGirl.create(:salary_head)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        day_count = Salary.salary_calculation_days salary_group_detail.id,28,25,28
        day_count.should eq(28)
      end

      it "should give present days as 25" do
        salary_head = FactoryGirl.create(:salary_head)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id,:based_on=>"Present Days")
        day_count = Salary.salary_calculation_days salary_group_detail.id,28,25,28
        day_count.should eq(25)
      end

      it "should give total days as 28" do
        salary_head = FactoryGirl.create(:salary_head)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id,:based_on=>"Independent Days")
        day_count = Salary.salary_calculation_days salary_group_detail.id,28,25,28
        day_count.should eq(28)
      end

    end


    describe "find employee Leave" do
      it "should find employee leave" do
        employee = FactoryGirl.create(:employee,:date_of_leaving => "2011-02-15",:leaving_reason => 'Without Reason')
        leave_definition = FactoryGirl.create(:leave_definition)
        leave_detail = FactoryGirl.create(:leave_detail,:leave_date => "2011-01-01", :employee_id => employee.id,:leave_definition_id=>leave_definition.id)
        getleave = Salary.find_employees_leave '2011-01-01', '2011-01-31', leave_detail.employee_id.to_s
        getleave.should eq(1)
      end
    end

    describe "get pt amount" do
      before(:each) do
        @pt_group = FactoryGirl.create(:pt_group)
        @branch = FactoryGirl.create(:branch,:pt_group_id => @pt_group.id)
        @salary_head = FactoryGirl.create(:salary_head)
      end

      it "should give pt amount within range defined with pt detail defined" do
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => @branch.id, :financial_institution_id => financial_institution.id)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
        salary = FactoryGirl.create(:salary, :salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pt_rate = FactoryGirl.create(:pt_rate,:pt_group_id => @pt_group.id, :paymonth_id => paymonth.id)
        pt_detail = FactoryGirl.create(:pt_detail,:branch_id => @branch.id,:pt_group_id => @pt_group.id,:pt_effective_date => '2011-01-01')
        get_pt = Salary.get_pt_amount "Feb/2011", salary.employee_id.to_s
        get_pt.should eq(100.00)
      end

      it "should give pt amount as 0 within range defined with pt detail defined after salary calculation date" do
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => @branch.id, :financial_institution_id => financial_institution.id)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
        salary = FactoryGirl.create(:salary, :salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pt_rate = FactoryGirl.create(:pt_rate,:pt_group_id => @pt_group.id,:paymonth_id => paymonth.id)
        pt_detail = FactoryGirl.create(:pt_detail,:branch_id => @branch.id,:pt_group_id => @pt_group.id,:pt_effective_date => '2011-03-01')
        get_pt = Salary.get_pt_amount "Feb/2011", salary.employee_id.to_s
        get_pt.should eq(0.0)
      end

      it "should give pt amount as 0 within range defined without pt detail defined" do
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => @branch.id, :financial_institution_id => financial_institution.id)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
        salary = FactoryGirl.create(:salary, :salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pt_rate = FactoryGirl.create(:pt_rate,:pt_group_id => @pt_group.id,:paymonth_id => paymonth.id)
        get_pt = Salary.get_pt_amount "Feb/2011", salary.employee_id.to_s
        get_pt.should eq(0.0)
      end

      it "should give pt amount outside the range defined" do
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => @branch.id, :financial_institution_id => financial_institution.id)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
        salary = FactoryGirl.create(:salary,:salary_amount => 17000, :salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pt_rate = FactoryGirl.create(:pt_rate,:min_sal_range => 15000.0, :max_sal_range => 25000, :pt=>250.0,:pt_group_id => @pt_group.id,:paymonth_id => paymonth.id)
        pt_detail = FactoryGirl.create(:pt_detail,:branch_id => @branch.id,:pt_group_id => @pt_group.id,:pt_effective_date => '2011-01-01')
        get_pt = Salary.get_pt_amount "Feb/2011", salary.employee_id.to_s
        get_pt.should eq(250.0)
      end

      it "should give pt amount outside the range defined" do
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => @branch.id, :financial_institution_id => financial_institution.id)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => @salary_head.id)
        salary = FactoryGirl.create(:salary,:salary_amount => 6000, :salary_head_id => @salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pt_rate = FactoryGirl.create(:pt_rate,:min_sal_range => 7000.0,:pt_group_id => @pt_group.id,:paymonth_id => paymonth.id)
        pt_detail = FactoryGirl.create(:pt_detail,:branch_id => @branch.id,:pt_group_id => @pt_group.id,:pt_effective_date => '2011-01-01')
        get_pt = Salary.get_pt_amount "Feb/2011", salary.employee_id.to_s
        get_pt.should eq(0)
      end

    end

    describe "get PF amount" do

      it "should give PF amount for selected employee and month" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        employee_statutory = FactoryGirl.create(:employee_statutory, :employee_id => employee.id)
        pf_group_rate = FactoryGirl.create(:pf_group_rate,:pf_group_id => pf_group.id, :paymonth_id => paymonth.id)


        salary = FactoryGirl.create(:salary,:salary_amount => 17000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pf_detail = FactoryGirl.create(:pf_detail,:branch_id => branch.id,:pf_group_id => pf_group.id,:pf_effective_date => '2011-01-01')

        pf_amount = Salary.get_pf_amount "Feb/2011", 1
        pf_amount.should eq(780.0)
      end

      it "should give PF amount for selected employee and month" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        employee_statutory = FactoryGirl.create(:employee_statutory, :employee_id => employee.id)
        pf_group_rate = FactoryGirl.create(:pf_group_rate,:pf_group_id => pf_group.id, :paymonth_id => paymonth.id)


        salary = FactoryGirl.create(:salary,:salary_amount => 6000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pf_detail = FactoryGirl.create(:pf_detail,:branch_id => branch.id,:pf_group_id => pf_group.id,:pf_effective_date => '2011-01-01')
        pf_amount = Salary.get_pf_amount "Feb/2011", 1
        pf_amount.should eq(720.0)
      end

      it "should not give PF amount for selected employee and month if pf_detail is defined after salary calculation date" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        pf_group_rate = FactoryGirl.create(:pf_group_rate,:pf_group_id => pf_group.id, :paymonth_id => paymonth.id)


        salary = FactoryGirl.create(:salary,:salary_amount => 17000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pf_detail = FactoryGirl.create(:pf_detail,:branch_id => branch.id,:pf_group_id => pf_group.id,:pf_effective_date => '2011-03-01')
        pf_amount = Salary.get_pf_amount "Feb/2011", 1
        pf_amount.should eq(0.0)
      end

      it "should not give PF amount for selected employee and month if pf_detail is not defined" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        pf_group_rate = FactoryGirl.create(:pf_group_rate,:pf_group_id => pf_group.id, :paymonth_id => paymonth.id)


        salary = FactoryGirl.create(:salary,:salary_amount => 17000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pf_amount = Salary.get_pf_amount "Feb/2011", 1
        pf_amount.should eq(0.0)
      end

      it "should not give PF amount for selected employee if pf restriction is applicable" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        pf_group = FactoryGirl.create(:pf_group)
        branch = FactoryGirl.create(:branch,:pf_group_id => pf_group.id)
        employee = FactoryGirl.create(:employee,:restrct_pf=>true)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        employee_statutory = FactoryGirl.create(:employee_statutory, :employee_id => employee.id)
        pf_group_rate = FactoryGirl.create(:pf_group_rate,:pf_group_id => pf_group.id, :paymonth_id => paymonth.id)


        salary = FactoryGirl.create(:salary,:salary_amount => 17000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        pf_detail = FactoryGirl.create(:pf_detail,:branch_id => branch.id,:pf_group_id => pf_group.id,:pf_effective_date => '2011-01-01')

        pf_amount = Salary.get_pf_amount "Feb/2011", 1
        pf_amount.should eq(0.0)
      end
    end

    describe "get ESI amount" do
      it "should give ESI amount as 0 for selected employee and month" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:esi_group_id => esi_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        esi_group_rate = FactoryGirl.create(:esi_group_rate,:esi_group_id => esi_group.id, :paymonth_id => paymonth.id)

        salary_allotment = FactoryGirl.create(:salary_allotment,:salary_allotment => 17000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        esi_detail = FactoryGirl.create(:esi_detail,:branch_id => branch.id,:esi_group_id => esi_group.id,:esi_effective_date => '2011-01-01')
        esi_amount = Salary.get_esi_amount "Feb/2011", 1
        esi_amount.should eq(0.0)
      end

      it "should give ESI amount for selected employee and month" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:esi_group_id => esi_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        esi_group_rate = FactoryGirl.create(:esi_group_rate,:esi_group_id => esi_group.id, :paymonth_id => paymonth.id)

        salary = FactoryGirl.create(:salary,:salary_amount => 15000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        esi_detail = FactoryGirl.create(:esi_detail,:branch_id => branch.id,:esi_group_id => esi_group.id,:esi_effective_date => '2011-01-01')
        esi_amount = Salary.get_esi_amount "Feb/2011", 1
        esi_amount.should eq(262.5)
      end

      it "should not give ESI amount for selected employee and month as qualifying amount is greater than cutoff" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:esi_group_id => esi_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        esi_group_rate = FactoryGirl.create(:esi_group_rate,:esi_group_id => esi_group.id, :paymonth_id => paymonth.id)

        salary = FactoryGirl.create(:salary,:salary_amount => 17000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        esi_detail = FactoryGirl.create(:esi_detail,:branch_id => branch.id,:esi_group_id => esi_group.id,:esi_effective_date => '2011-01-01')
        esi_amount = Salary.get_esi_amount "Feb/2011", 1
        esi_amount.should eq(0.0)
      end

      it "should not give ESI amount for selected employee and month if esi group is defined after salary calculation date" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:esi_group_id => esi_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        esi_group_rate = FactoryGirl.create(:esi_group_rate,:esi_group_id => esi_group.id, :paymonth_id => paymonth.id)

        salary = FactoryGirl.create(:salary,:salary_amount => 15000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        esi_detail = FactoryGirl.create(:esi_detail,:branch_id => branch.id,:esi_group_id => esi_group.id,:esi_effective_date => '2011-03-01')
        esi_amount = Salary.get_esi_amount "Feb/2011", 1
        esi_amount.should eq(0.0)
      end

      it "should give ESI amount as 0 for selected employee and month if esi group is not defined" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        branch = FactoryGirl.create(:branch,:esi_group_id => nil)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)

        salary_allotment = FactoryGirl.create(:salary_allotment,:salary_allotment => 15000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        esi_amount = Salary.get_esi_amount "Feb/2011", 1
        esi_amount.should eq(0.0)
      end

      it "should not give ESI amount for selected employee and month if esi_detail is not defined" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:esi_group_id => esi_group.id)
        employee = FactoryGirl.create(:employee)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        esi_group_rate = FactoryGirl.create(:esi_group_rate,:esi_group_id => esi_group.id, :paymonth_id => paymonth.id)

        salary_allotment = FactoryGirl.create(:salary_allotment,:salary_allotment => 15000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        esi_amount = Salary.get_esi_amount "Feb/2011", 1
        esi_amount.should eq(0.0)
      end

      it "should not give ESI amount for selected employee and month if esi is restricted" do
        salary_head = FactoryGirl.create(:salary_head)
        paymonth = FactoryGirl.create(:paymonth)
        salary_group_detail = FactoryGirl.create(:salary_group_detail, :salary_head_id => salary_head.id)
        attendance_configuration = FactoryGirl.create(:attendance_configuration)
        financial_institution = FactoryGirl.create(:financial_institution)
        esi_group = FactoryGirl.create(:esi_group)
        branch = FactoryGirl.create(:branch,:esi_group_id => esi_group.id)
        employee = FactoryGirl.create(:employee,:restrict_esi=>true)
        employee_detail = FactoryGirl.create(:employee_detail,:attendance_configuration_id => attendance_configuration.id,:branch_id => branch.id, :financial_institution_id => financial_institution.id)
        esi_group_rate = FactoryGirl.create(:esi_group_rate,:esi_group_id => esi_group.id, :paymonth_id => paymonth.id)

        salary_allotment = FactoryGirl.create(:salary_allotment,:salary_allotment => 16000, :salary_head_id => salary_head.id, :salary_group_detail_id => salary_group_detail.id)
        esi_amount = Salary.get_esi_amount "Feb/2011", 1
        esi_amount.should eq(0.0)
      end
    end

  end

end