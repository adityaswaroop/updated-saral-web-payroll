require 'spec_helper'

describe LeaveTaken do


  it "should return employee name" do
    employee = FactoryGirl.create(:employee)
    leave_taken = FactoryGirl.create(:leave_taken,:employee_id=>employee.id)
    employee_name = leave_taken.employee_name
    employee_name.should eq(employee.empname)
  end

  it "should convert the date and save" do
    @date_format = DateFormat.create(:date_format=>"m/d/Y",:date_format_value=>"%m/%d/%Y")
    @option_setting = OptionSetting.create(:salary_calc => 'Jan/2012',:date_format => "m/d/Y")
    employee = FactoryGirl.create(:employee)
    leav_taken={"0"=>{"leave_count"=>"1", "leave_from_date"=>"06/06/2012", "leave_to_date"=>"06/07/2012", "lop_count"=>"", "lop_from_date"=>"", "lop_to_date"=>"", "employee_id"=>employee.id}, "1"=>{"leave_count"=>"", "leave_from_date"=>"", "leave_to_date"=>"", "lop_count"=>"", "lop_from_date"=>"", "lop_to_date"=>"", "employee_id"=>employee.id}}
    LeaveTaken.save_leaves leav_taken,"jan/2012"
    LeaveTaken.count.should eq(1)
  end

  describe "create leave taken with date format of Y-m-d" do
     it "should create the leave taken" do
       @date_format = FactoryGirl.create(:date_format)
      @option_setting = FactoryGirl.create(:option_setting)
       employee = FactoryGirl.create(:employee)
       leav_taken={"0"=>{"leave_count"=>"1", "leave_from_date"=>"2012-06-06", "leave_to_date"=>"2012-06-07", "lop_count"=>"", "lop_from_date"=>"", "lop_to_date"=>"", "employee_id"=>employee.id}, "1"=>{"leave_count"=>"", "leave_from_date"=>"", "leave_to_date"=>"", "lop_count"=>"", "lop_from_date"=>"", "lop_to_date"=>"", "employee_id"=>employee.id}}
       LeaveTaken.save_leaves leav_taken,"jan/2012"
       LeaveTaken.count.should eq(1)
     end
  end

end
