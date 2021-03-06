require 'spec_helper'

describe CompaniesController do
  before :each do
    controller.stub(:logged_in?).and_return(true)
    @file_specs= FactoryGirl.create(:upload_file_type)
    @date_format = FactoryGirl.create(:date_format)
    @option_setting = FactoryGirl.create(:option_setting)
  end

  def valid_attributes
    {:companyname => "Its My company Ltd.",
    :responsible_person => "Myself",
    :address => "My company address",
    :website => "www.mycompany.com",
    :dateofestablishment => "2010-10-30",
    :pf => true,
    :esi => true,
    :phonenumber1 => "080201256",
    :phonenumber2 => "080201256" ,
    :address2 => "My company address 2",
    :address3 => "My company address 3",
    :email => "mycomap@comp.com"}
  end

  def update_valid_attributes
    {:companyname => "Its My company Ltd.",
    :responsible_person => "Myself",
    :address => "My company address",
    :website => "www.mycompany.com",
    :dateofestablishment => "10/30/2010",
    :pf => true,
    :esi => true,
    :phonenumber1 => "080201256",
    :phonenumber2 => "080201256" ,
    :address2 => "My company address 2",
    :address3 => "My company address 3",
    :email => "mycomap@comp.com"}
  end

    describe "GET index" do
      it "assigns the first company as @company" do
        company = Company.create! valid_attributes
        get :index
        assigns(:company).should eq(company)
      end
    end

    describe "GET new" do
      it "assigns a new company as @company" do
        get :new
        assigns(:company).should be_a_new(Company)
      end
    end

    describe "GET edit" do
      it "assigns the requested company as @company" do
        company = Company.create! valid_attributes
        get :edit, :id => company.id
        assigns(:company).should eq(company)
      end
    end

    describe "POST create" do

      describe "with valid params" do
        it "creates a new Company" do
          expect {
            post :create, :company => valid_attributes
          }.to change(Company, :count).by(1)
        end

        it "assigns a newly created company as @company" do
          post :create, :company => valid_attributes
          assigns(:company).should be_a(Company)
          assigns(:company).should be_persisted
        end
      end

      describe "create with date format of %m/%d/%Y" do
        it "should create employee statutory detail  with converted date format" do
          DateFormat.first.update_attributes(:date_format => "m/d/Y",:date_format_value=>"%m/%d/%Y")
          OptionSetting.first.update_attribute("date_format","m/d/Y")
          expect {
            post :create, {:company => update_valid_attributes}
          }.to change(Company, :count).by(1)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved company as @company" do
          Company.any_instance.stub(:save).and_return(false)
          post :create, :company => {}
          assigns(:company).should be_a_new(Company)
        end

        it "re-renders the 'new' template" do
          Company.any_instance.stub(:save).and_return(false)
          post :create, :company => {}
          response.should render_template("new")
        end
      end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the Company" do
          company = Company.create! valid_attributes
          Company.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => company.id, :company => {'these' => 'params'}
        end

        it "assigns the requested company as @company" do
          company = Company.create! valid_attributes
          put :update, :id => company.id, :companyname => valid_attributes
          assigns(:company).should eq(company)
        end
      end

      describe "update with date format of %m/%d/%Y" do
        it "should update employee statutory details with converted date format" do
          DateFormat.first.update_attributes(:date_format => "m/d/Y",:date_format_value=>"%m/%d/%Y")
          OptionSetting.first.update_attribute("date_format","m/d/Y")
          company = Company.create! valid_attributes
          put :update, :id => company.id, :company => update_valid_attributes
          assigns(:company).should eq(company)
        end
      end
    end


    describe "with invalid params" do
      it "assigns the company as @company" do
        company = Company.create! valid_attributes
        Company.any_instance.stub(:save).and_return(false)
        put :update, :id => company.id, :company => {}
        assigns(:company).should eq(company)
      end

      it "re-renders the 'edit' template" do
        company = Company.create! valid_attributes
        Company.any_instance.stub(:save).and_return(false)
        put :update, :id => company.id, :company => {}
        response.should render_template("edit")
      end
    end
  end

  describe "GET documents_list" do
    before (:each)  do
      @company = FactoryGirl.create(:company,:photo => Rails.root.join("spec/factories/icon_a.png").open)
    end
    it "should list all the Company Documents" do

       get :documents_list, :id => @company.id
       assigns(:list).should eq(@company.company_documents)
     end
  end

  describe "GET Backup" do
    it "should display the file" do
      company = FactoryGirl.create(:company)
      get :backup
      assigns(:company).should eq(company)
      response.should be_success
    end
  end

  describe "POST backup_option" do
    it "backups Skeleton" do
      post :backup_option, :backup_option => "Skeleton"
      response.should be_success
    end
    it "backups Schema with data" do
      post :backup_option, :backup_option => "Data Backup"
      response.should be_success
    end
  end

  describe "GET Restore" do
    it "should restore schema with full data backup file" do
      FactoryGirl.create(:employee)
      dump_file = fixture_file_upload("spec/factories/Backup-04-06-2012-11h56m09s.db")
      BackupUtility.create!(:backup_date => Time.now.strftime('%d-%m-%Y'), :file_hash => dump_file.hash, :employees_count => Employee.count, :last_sal_calculated => "01-01-12", :backup_option => "Schema", :file_name => dump_file.original_filename)
      post :restore, :dump_file => dump_file
      response.should be_success

      post :restore_backup, :file => "public/excel_uploaded_files/Backup-04-06-2012-11h56m09s.db"
      response.should redirect_to companies_path
    end

    it "should restore data only backup file" do
      FactoryGirl.create(:employee)
      dump_file = fixture_file_upload("spec/factories/Backup-04-06-2012-12h43m09s.db")
      BackupUtility.create!(:backup_date => Time.now.strftime('%d-%m-%Y'), :file_hash => dump_file.hash, :employees_count => Employee.count, :last_sal_calculated => "01-01-12", :backup_option => "Data Backup", :file_name => dump_file.original_filename)
      post :restore, :dump_file => dump_file
      response.should be_success

      post :restore_backup, :file => "public/excel_uploaded_files/Backup-04-06-2012-12h43m09s.db", :backup_option => "Data Backup"
      response.should redirect_to companies_path
    end


  end
end

