require 'spec_helper'

describe LeaveTakensController do

  before :each do
    controller.stub(:logged_in?).and_return(true)
    @date_format = FactoryGirl.create(:date_format)
    @option_setting = FactoryGirl.create(:option_setting)
  end
  def valid_attributes
    {
        :employee_id => 1,
        :leave_detail_date => 'jan-2012',
        :leave_count => 1,
        :lop_count => 2
    }
  end

  describe "GET index" do
    it "assigns all leave_takens as @leave_takens" do
      employee = FactoryGirl.create(:employee)
      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
      get :index, {}
      assigns(:leave_takens).should eq([leave_taken])
    end
  end

  #describe "GET show" do
  #  it "assigns the requested leave_taken as @leave_taken" do
  #    employee = FactoryGirl.create(:employee)
  #    leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
  #    get :show, {:id => leave_taken.to_param}
  #    assigns(:leave_taken).should eq(leave_taken)
  #  end
  #end

  describe "GET new" do
    it "assigns a new leave_taken as @leave_taken" do
      get :new, {}
      assigns(:leave_taken).should be_a_new(LeaveTaken)
    end

    it "loads the grid with employee list when leave detail date is passes" do
      get :new, {:leave_detail_date => 'Jan/2012',:show_emp_list=>'true'}
      assigns(:leave_taken).should be_a_new(LeaveTaken)
    end
  end

  #describe "GET edit" do
  #  it "assigns the requested leave_taken as @leave_taken" do
  #    employee = FactoryGirl.create(:employee)
  #    leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
  #    get :edit, {:id => leave_taken.to_param}
  #    assigns(:leave_taken).should eq(leave_taken)
  #  end
  #end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new LeaveTaken" do
        expect {
          employee = FactoryGirl.create(:employee)
          post :create, {:leave_taken => {"leave_detail_date"=>"Oct/2012"},:leave_takens=>{"0"=>{"leave_count"=>"2", "leave_from_date"=>"2012-06-01", "leave_to_date"=>"2012-06-02", "lop_count"=>"3", "lop_from_date"=>"2012-06-13", "lop_to_date"=>"2012-06-15", "employee_id"=>employee.id}}}
        }.to change(LeaveTaken, :count).by(1)
      end

      it "assigns a newly created leave_taken as @leave_taken" do
        employee = FactoryGirl.create(:employee)
        post :create, {:leave_taken => {"leave_detail_date"=>"Oct/2012"},:leave_takens=>{"0"=>{"leave_count"=>"2", "leave_from_date"=>"2012-06-01", "leave_to_date"=>"2012-06-02", "lop_count"=>"3", "lop_from_date"=>"2012-06-13", "lop_to_date"=>"2012-06-15", "employee_id"=>employee.id}}}
        #assigns(:leave_taken).should be_a(LeaveTaken)
        #assigns(:leave_takens[1]).should be_persisted
      end

      it "redirects to the index page" do
        employee = FactoryGirl.create(:employee)
        post :create,{:leave_taken => {"leave_detail_date"=>"Oct/2012"},:leave_takens=>{"0"=>{"leave_count"=>"2", "leave_from_date"=>"2012-06-01", "leave_to_date"=>"2012-06-02", "lop_count"=>"3", "lop_from_date"=>"2012-06-13", "lop_to_date"=>"2012-06-15", "employee_id"=>employee.id}}}
        response.should redirect_to(leave_takens_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved leave_taken as @leave_taken" do
        LeaveTaken.any_instance.stub(:save).and_return(false)
        post :create, {:leave_taken => {"leave_detail_date"=>"Oct/2012"}}
        #assigns(:leave_taken).should be_a_new(LeaveTaken)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        LeaveTaken.any_instance.stub(:save).and_return(false)
        post :create, {:leave_taken => {"leave_detail_date"=>"Oct/2012"}}
        response.should redirect_to(leave_takens_path)
      end
    end
  end

  #describe "PUT update" do
  #  describe "with valid params" do
  #    it "updates the requested leave_taken" do
  #      employee = FactoryGirl.create(:employee)
  #      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
  #      LeaveTaken.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
  #      put :update, {:id => leave_taken.to_param, :leave_taken => {'these' => 'params'}}
  #    end
  #
  #    it "assigns the requested leave_taken as @leave_taken" do
  #      employee = FactoryGirl.create(:employee)
  #      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
  #      put :update, {:id => leave_taken.to_param, :leave_taken => valid_attributes}
  #      assigns(:leave_taken).should eq(leave_taken)
  #    end
  #
  #    it "redirects to the leave_taken" do
  #      employee = FactoryGirl.create(:employee)
  #      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
  #      put :update, {:id => leave_taken.to_param, :leave_taken => valid_attributes}
  #      response.should redirect_to(leave_takens_path)
  #    end
  #  end
  #
  #  describe "with invalid params" do
  #    it "assigns the leave_taken as @leave_taken" do
  #      employee = FactoryGirl.create(:employee)
  #      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      LeaveTaken.any_instance.stub(:save).and_return(false)
  #      put :update, {:id => leave_taken.to_param, :leave_taken => {}}
  #      assigns(:leave_taken).should eq(leave_taken)
  #    end
  #
  #    it "re-renders the 'edit' template" do
  #      employee = FactoryGirl.create(:employee)
  #      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      LeaveTaken.any_instance.stub(:save).and_return(false)
  #      put :update, {:id => leave_taken.to_param, :leave_taken => {}}
  #      response.should render_template("edit")
  #    end
  #  end
  #end

  describe "DELETE destroy" do
    it "destroys the requested leave_taken" do
      employee = FactoryGirl.create(:employee)
      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
      expect {
        delete :destroy, {:id => leave_taken.to_param}
      }.to change(LeaveTaken, :count).by(-1)
    end

    it "redirects to the leave_takens list" do
      employee = FactoryGirl.create(:employee)
      leave_taken = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
      delete :destroy, {:id => leave_taken.to_param}
      response.should redirect_to(leave_takens_url)
    end
  end

  describe " Post Excel File Upload, Parse and Save" do
    it "parse, validate and redirects to save page with no error message" do
      employee = FactoryGirl.create(:employee)
      leaves = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
      excel_file = fixture_file_upload("spec/factories/Leave_taken.xls")
      post :upload_parse_validate, :excel_file => excel_file
      response.should be_success
    end

    it "parse and validate and redirects to upload with error message" do
      employee = FactoryGirl.create(:employee)
      leaves = LeaveTaken.create! valid_attributes.merge(:employee_id => employee.id)
      excel_file = fixture_file_upload("spec/factories/Leave_taken_dup_col.xls")
      post :upload_parse_validate, :excel_file => excel_file
      response.should be_success
    end

    it "save excel upload data" do
      employee = FactoryGirl.create(:employee)
      post :save, :leaves_takens => [{"employee_id"=>employee.id,"leave_detail_date"=>"Oct/2012", "leave_count"=>"2.0", "lop_count"=>"2.0"}]
      response.should redirect_to leave_takens_path
    end
  end

  describe "Generate Sample excel sheet template" do
    it "should render template excel sheet" do
      get :generate_sample_excel_template, :format => "xls"
      response.should render_template('leave_takens/generate_sample_excel_template')
    end
  end
end
