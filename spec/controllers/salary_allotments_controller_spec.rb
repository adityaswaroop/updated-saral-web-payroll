require 'spec_helper'

describe SalaryAllotmentsController do
  before :each do
    controller.stub(:logged_in?).and_return(true)
  end

  describe "Index" do
    it "gets employee whose salary is not allotted" do
      employee = FactoryGirl.create(:employee)
      salary_head = FactoryGirl.create(:salary_head)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
      need_to_allot_Sal = FactoryGirl.create(:salary_allotment,:salary_allotment=>0,:employee_id=>employee.id,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id)
      get :index
      assigns(:need_to_allot_Sal).should be_true
    end

    it "gets employee whose salary is allotted" do
      employee = FactoryGirl.create(:employee)
      salary_head = FactoryGirl.create(:salary_head)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
      already_allot_Sal = FactoryGirl.create(:salary_allotment,:employee_id=>employee.id,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id)
      get :index
      assigns(:already_allot_Sal).should be_true
    end
  end

  describe "Edit" do
    it "assigns the requested employee for salary allotment" do
      employee = FactoryGirl.create(:employee)
      salary_head = FactoryGirl.create(:salary_head)
      salary_group = FactoryGirl.create(:salary_group)
      attendance_configuration = FactoryGirl.create(:attendance_configuration)
      financial_institution = FactoryGirl.create(:financial_institution)
      branch = FactoryGirl.create(:branch)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_group_id=>salary_group.id,:salary_head_id=>salary_head.id)
      employee_detail = FactoryGirl.create(:employee_detail, :employee_id => employee.id, :salary_group_id => salary_group.id, :financial_institution_id => financial_institution.id,:branch_id=>branch.id,:attendance_configuration_id=>attendance_configuration.id)
      salary_allotment = FactoryGirl.create(:salary_allotment,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id,:employee_detail_id=>employee_detail.id)
      get :edit, :id => salary_allotment.employee_id
      assigns(:allotSal_earnings).should eq([salary_allotment])
    end

    it "assigns the requested employee for salary allotment with paymonth" do
      pay_month =  FactoryGirl.create(:paymonth, :month_year => 24134, :number_of_days => 28,:from_date => "2011-02-01",:to_date => "2011-02-28",:month_name => "Feb/2011")
      employee = FactoryGirl.create(:employee)
      salary_head = FactoryGirl.create(:salary_head)
      salary_group = FactoryGirl.create(:salary_group)
      attendance_configuration = FactoryGirl.create(:attendance_configuration)
      financial_institution = FactoryGirl.create(:financial_institution)
      branch = FactoryGirl.create(:branch)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_group_id=>salary_group.id,:salary_head_id=>salary_head.id)
      employee_detail = FactoryGirl.create(:employee_detail, :employee_id => employee.id, :salary_group_id => salary_group.id, :financial_institution_id => financial_institution.id,:branch_id=>branch.id,:attendance_configuration_id=>attendance_configuration.id)
      salary_allotment = FactoryGirl.create(:salary_allotment,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id,:employee_detail_id=>employee_detail.id)
      get :edit, :id => salary_allotment.employee_id,:month_year=>pay_month.month_name
      assigns(:allotSal_earnings).should eq([salary_allotment])
    end
  end

  describe "Update" do
    it "should update the salary allotted amount" do
      salary_head = FactoryGirl.create(:salary_head)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
      salAllot = FactoryGirl.create(:salary_allotment,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id)
      post :update, :id => salAllot.id, :salAllotment => [salAllot.attributes.merge(:salary_allotment => 2222.00,:month_year=>"Feb/2011")]
      SalaryAllotment.find_by_id(salAllot.id)[:salary_allotment].should eq(2222.00)
    end

    it "should insert the salary allotted amount of month_year is different from effective date" do
      salary_head = FactoryGirl.create(:salary_head)
      salary_group_detail = FactoryGirl.create(:salary_group_detail,:salary_head_id=>salary_head.id)
      salAllot = FactoryGirl.create(:salary_allotment,:salary_group_detail_id=>salary_group_detail.id,:salary_head_id=>salary_head.id)
      expect {
        post :update, :id => salAllot.id, :salAllotment => [salAllot.attributes.merge(:salary_allotment => 2222.00,:month_year=>"Mar/2011")]}.to change(SalaryAllotment, :count).by(1)
    end
  end

  describe "Excel File Upload, Parse and Save" do

    before :each do
      @employee = FactoryGirl.create(:employee)
      @basic = FactoryGirl.create(:salary_head)
      @da = FactoryGirl.create(:salary_head, :head_name => "DA",  :short_name => "DA")
      @hra = FactoryGirl.create(:salary_head, :head_name => "HRA",  :short_name => "HRA")
      @sal_grp = FactoryGirl.create(:salary_group)
      paymonth = FactoryGirl.create(:paymonth)
      @sal_grp_det1 = FactoryGirl.create(:salary_group_detail, :salary_group_id => @sal_grp.id, :salary_head_id => @basic.id)
      @sal_grp_det2 = FactoryGirl.create(:salary_group_detail, :salary_group_id => @sal_grp.id, :salary_head_id => @da.id)
      @sal_grp_det3 = FactoryGirl.create(:salary_group_detail, :salary_group_id => @sal_grp.id, :salary_head_id => @hra.id)
      @attn_config = FactoryGirl.create(:attendance_configuration)
      @fin_insti = FactoryGirl.create(:financial_institution)
      @branch = FactoryGirl.create(:branch)
      @employee_detail = FactoryGirl.create(:employee_detail, :employee_id => @employee.id, :salary_group_id => @sal_grp.id, :financial_institution_id => @fin_insti.id)
      SalaryAllotment.create(:employee_id => @employee.id, :employee_detail_id => @employee_detail.id, :effective_date => @employee_detail.effective_date, :salary_head_id => @sal_grp_det1.salary_head_id, :salary_group_detail_id => @sal_grp_det1.id, :salary_allotment =>0)
      SalaryAllotment.create(:employee_id => @employee.id, :employee_detail_id => @employee_detail.id, :effective_date => @employee_detail.effective_date, :salary_head_id => @sal_grp_det2.salary_head_id, :salary_group_detail_id => @sal_grp_det2.id, :salary_allotment =>0)
      SalaryAllotment.create(:employee_id => @employee.id, :employee_detail_id => @employee_detail.id, :effective_date => @employee_detail.effective_date, :salary_head_id => @sal_grp_det3.salary_head_id, :salary_group_detail_id => @sal_grp_det3.id, :salary_allotment =>0)
    end

    it "save_parse_validate" do
      excel_file = fixture_file_upload("spec/factories/Template_Theoretical_Salary.xls")
      post :upload_parse_validate, :excel_file => excel_file
      response.should redirect_to(salary_allotments_path(:param1 => "allotted"))
    end

    it "gives error for duplication of heads" do
      excel_file = fixture_file_upload("spec/factories/Template_Theoretical_Salary  Duplication.xls")
      post :upload_parse_validate, :excel_file => excel_file
      response.should be_success
    end

    it "gives error No allotment for salary head" do
      excel_file = fixture_file_upload("spec/factories/Template_Theoretical_Salary_No_allot.xls")
      post :upload_parse_validate, :excel_file => excel_file
      response.should be_success
    end

  end

  describe "Generate Sample excel sheet template" do
    it "should render template excel sheet" do
      get :generate_sample_excel_template, :format => "xls"
      response.should render_template('salary_allotments/generate_sample_excel_template')
    end
  end

end