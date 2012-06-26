require 'spec_helper'


describe EmployeesController do
  before :each do
    controller.stub(:logged_in?).and_return(true)
    @date_format = FactoryGirl.create(:date_format)
    @option_setting = FactoryGirl.create(:option_setting)
  end


  def valid_attributes
    {
      :empname => "GaneshL",
      :date_of_joining => "2009-10-31",
      :date_of_leaving => "2010-11-30",
      :present_state_id => "1",
      :refno => "A1",
      :email => "ganny@gnaa.com",
      :restrct_pf => false,
      :restrict_esi => false
    }
  end

  def update_employee_attributes
    {
        :empname => "GaneshL",
        :date_of_joining => "10/31/2009",
        :date_of_leaving => "",
        :present_state_id => "1",
        :refno => "A1",
        :email => "ganny@gnaa.com",
        :restrct_pf => false,
        :restrict_esi => false
    }
  end

  describe "Excel File Upload, Parse and Save" do

    before :each do
      @state = FactoryGirl.create(:state)
    end

    it "save_parse_validate" do
      excel_file = fixture_file_upload("spec/factories/Employee_Test.xls")
      post :upload_parse_validate, :excel_file => excel_file
      response.should redirect_to(employees_path)
    end

    it "updates existing employee" do
      emp = FactoryGirl.create(:employee, :refno => 1004)
      excel_file = fixture_file_upload("spec/factories/Employee_Test_Update.xls")
      post :upload_parse_validate, :excel_file => excel_file
      Employee.find_by_refno(emp.refno.to_s).email.should eq('Ranjeet.kumar@relyonsoft.com')
    end

    it "gives error" do
      excel_file = fixture_file_upload("spec/factories/Employee_widout_empname.xls")
      post :upload_parse_validate, :excel_file => excel_file

      response.should be_success
    end

    it "gives error for duplication of columns" do
      excel_file = fixture_file_upload("spec/factories/Employee_Test_Hd_Dup.xls")
      post :upload_parse_validate, :excel_file => excel_file
      response.should be_success
    end
  end

  describe "GET index" do
    before :each do
      @employee = FactoryGirl.create(:employee)
    end
    it "assigns all employees as @employees" do
      get :index
      assigns(:employees).should eq([@employee])
    end

    it "search all employee for entered keyword" do
      get :index, :search => 'XYZ'
      assigns(:employees).should eq([@employee])
    end
  end

  describe "GET show" do
    it "assigns the requested employee as @employee" do
      employee = FactoryGirl.create(:employee)
      get :show, :id => employee.id
      assigns(:employee).should eq(employee)
    end
  end

  describe "GET new" do
    it "assigns a new employee as @employee" do
      get :new
      assigns(:employee).should be_a_new(Employee)
    end
  end

  describe "GET edit" do
    it "assigns the requested employee as @employee" do
      employee = FactoryGirl.create(:employee)
      get :edit, :id => employee.id
      assigns(:employee).should eq(employee)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      before :each do
        @employee = FactoryGirl.build(:employee)
      end
      it "Count should be increases by one" do
        expect {
          post :create, :employee => @employee.attributes
        }.to change(Employee, :count).by(1)
      end

      it "assigns a newly created employee as @employee" do
        post :create, :employee => @employee.attributes
        assigns(:employee).should be_a(Employee)
        assigns(:employee).should be_persisted
      end

      it "redirects to the created employee" do
        post :create, :employee => @employee.attributes
        response.should redirect_to(Employee.last)
      end
    end

    describe "create with date format of %m/%d/%Y" do
      it "should create employee with converted date format" do
        DateFormat.first.update_attributes(:date_format => "m/d/Y",:date_format_value=>"%m/%d/%Y")
        OptionSetting.first.update_attribute("date_format","m/d/Y")
        post :create, :employee => update_employee_attributes
        assigns(:employee).should be_a(Employee)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved employee as @employee" do
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        post :create, :employee => {}
        assigns(:employee).should be_a_new(Employee)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        post :create, :employee => {}
        response.should render_template("new")
      end
    end
  end

  describe "update with date format of %m/%d/%Y" do
    before :each do
      @employee = FactoryGirl.create(:employee)
    end
    it "should create employee with converted date format" do
      DateFormat.first.update_attributes(:date_format => "m/d/Y",:date_format_value=>"%m/%d/%Y")
      OptionSetting.first.update_attribute("date_format","m/d/Y")
      put :update, :id => @employee.id, :employee => update_employee_attributes
      response.should redirect_to(@employee)
    end
  end


  describe "PUT update" do
    describe "with valid params" do
      before :each do
        @employee = FactoryGirl.create(:employee)
      end
      it "updates the requested employee" do
        Employee.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => @employee.id, :employee => {'these' => 'params'}
      end

      it "assigns the requested employee as @employee" do
        put :update, :id => @employee.id, :employee => @employee.attributes
        assigns(:employee).should eq(@employee)
      end

      it "redirects to the employee" do
        put :update, :id => @employee.id, :employee => @employee.attributes
        response.should redirect_to(@employee)
      end
    end

    describe "with invalid params" do
      it "assigns the employee as @employee" do
        employee = FactoryGirl.create(:employee)
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        put :update, :id => employee.id, :employee => {}
        assigns(:employee).should eq(employee)
      end

      it "re-renders the 'edit' template" do
        employee = FactoryGirl.create(:employee)
        # Trigger the behavior that occurs when invalid params are submitted
        Employee.any_instance.stub(:save).and_return(false)
        put :update, :id => employee.id, :employee => {}
        response.should render_template("edit")
      end
    end
  end

  describe "GET report" do
    it "should generate report for other than contact info" do
      employees = FactoryGirl.create(:employee)
      get :report, :report_type => 'date_of_joining', "report"=>{}
      assigns(:employees).should_not be_nil
    end

    it "should generate report for contact info" do
      employees = FactoryGirl.create(:employee)
      get :report, :report_type => 'Contact', "report"=>{}
      assigns(:employees).should_not be_nil
    end

    it "generates pdf output" do
      employees = FactoryGirl.create(:employee)
      get :report, :report_type => 'Contact', "report"=>{}, :format => "pdf"
      response.should render_template('employees/report')
    end

    it "should generate report for other than contact info with classification search" do
      employees = FactoryGirl.create(:employee)
      get :report, :report_type => 'date_of_joining', "report"=>{"classification"=>{"Department"=>""}}
      assigns(:employees).should_not be_nil
    end

    it "should generate report for contact info with classification search" do
      employees = FactoryGirl.create(:employee)
      get :report, :report_type => 'Contact', "report"=>{"classification"=>{"Department"=>""}}
      assigns(:employees).should_not be_nil
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested employee" do
      employee = FactoryGirl.create(:employee)
      expect {
        delete :destroy, :id => employee.id
      }.to change(Employee, :count).by(-1)
    end

    it "redirects to the employees list" do
      employee = FactoryGirl.create(:employee)
      delete :destroy, :id => employee.id
      response.should redirect_to(employees_url)
    end
  end

  describe "GET pf_contribution_restrict" do
    before :each do
      @employee = FactoryGirl.create(:employee)
    end
    it "assigns all employees as @employees" do
      get :pf_contribution_restrict
      assigns(:employeesList).should eq([@employee])
    end

    it "assigns all employees as @employees" do
      get :pf_contribution_restrict, :search => "XYZ"
      assigns(:employeesList).should eq([@employee])
    end
  end

  describe "pf_esi_restrict_update" do

    before :each do
      @employee=FactoryGirl.create(:employee)
    end

    it "should update employees restrict_pf Value for true" do
      put :pf_restrict_update,:employee_data => [:id => @employee.id, :pf => true]
      Employee.find_by_id(@employee.id)[:restrct_pf].should eq(true)
    end

    it "should update employees restrict_pf Value for false" do
      put :pf_restrict_update,:employee_data => [:id => @employee.id, :pf => nil]
      Employee.find_by_id(@employee.id)[:restrct_pf].should eq(false)
    end

    it "should update employees restrict_esi Value for true" do
      put :pf_restrict_update,:employee_data => [:id => @employee.id, :esi => true]
      Employee.find_by_id(@employee.id)[:restrict_esi].should eq(true)
    end

    it "should update employees restrict_esi Value for false" do
      put :pf_restrict_update,:employee_data => [:id => @employee.id, :esi => nil]
      Employee.find_by_id(@employee.id)[:restrict_esi].should eq(false)
    end
  end

  describe "Generate Sample excel sheet template" do
    it "should render template excel sheet" do
      get :generate_sample_excel_template, :format => "xls"
      response.should render_template('employees/generate_sample_excel_template')
    end
  end

end
