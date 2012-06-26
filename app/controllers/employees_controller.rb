class EmployeesController < ApplicationController
  require 'will_paginate/array'

  before_filter :find_employee, :only => [:show, :edit, :update, :destroy]

  def index
    if params[:search]
      @employees = Employee.order('created_at ASC').search(params[:search]).paginate(:page => params[:page], :per_page => 10)
    else
      @employees = Employee.order('created_at ASC').paginate(:page => params[:page], :per_page => 10)
    end

    respond_to do |format|
      format.js
      format.html # show.html.haml
      format.json { render json: @employees }
    end
  end

  def show
    @hr_categories = HrCategory.all
    @statutory = EmployeeStatutory.find_by_employee_id(params[:id])
    @employee_detail = EmployeeDetail.find_by_employee_id(params[:id])
    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @employee }
    end
  end

  def new
    @employee = Employee.new

    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @employee }
    end
  end

  def edit

  end

  def create
    employee=params[:employee]
    @employee = Employee.new(params[:employee])
    #date_format=OptionSetting.date_format_value
    #if date_format == "%m-%Y-%d" || date_format == "%m/%d/%Y" || date_format == "%d/%m/%y" || date_format == "%d-%m-%y"
    #  dates_value=[employee[:date_of_birth],employee[:date_of_joining], employee[:probation_complete_date], employee[:salary_start_date], employee[:confirmation_date], employee[:date_of_leaving], employee[:retirement_date], employee[:resignation_date]]
    #  dates=OptionSetting.convert_date(dates_value)
    #  val=employee.merge!(:date_of_birth=>dates[0],:date_of_joining=>dates[1],:probation_complete_date=>dates[2],:salary_start_date=>dates[3], :confirmation_date=>dates[4], :date_of_leaving=>dates[5],:retirement_date=>dates[6],:resignation_date=>dates[7])
    #  @employee = Employee.new(val)
    #else
    #  @employee = Employee.new(params[:employee])
    #end
    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render json: @employee, status: :created, location: @employee }
      else
        format.html { render 'new' }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    date_format=OptionSetting.date_format_value
    if date_format == "%m-%Y-%d" || date_format == "%m/%d/%Y" || date_format == "%d/%m/%y" || date_format == "%d-%m-%y"
      dates_value=[params[:employee][:date_of_birth],params[:employee][:date_of_joining], params[:employee][:probation_complete_date], params[:employee][:salary_start_date], params[:employee][:confirmation_date], params[:employee][:date_of_leaving], params[:employee][:retirement_date], params[:employee][:resignation_date]]
      dates=OptionSetting.convert_date(dates_value)
      params[:employee].merge!(:date_of_birth=>dates[0],:date_of_joining=>dates[1],:probation_complete_date=>dates[2],:salary_start_date=>dates[3], :confirmation_date=>dates[4], :date_of_leaving=>dates[5],:retirement_date=>dates[6],:resignation_date=>dates[7])
    else
      params[:employee]
    end
    respond_to do |format|
        if @employee.update_attributes(params[:employee])
          format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render 'edit' }
          format.json { render json: @employee.errors, status: :unprocessable_entity }
        end
      end
  end

  def destroy
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to employees_url }
      format.json { head :ok }
    end
  end

  # Upload excel sheet for bulk insertion employee
  def upload

  end

  # save , parse and validate the excel file
  def upload_parse_validate
    test_file = params[:excel_file]
    file = FileUploader.new
    file.store!(test_file)
    book = Spreadsheet.open "#{file.store_path}"
    sheet1 = book.worksheet 0

    @employees = Employee.process_employee_excel_sheet sheet1

    if @employees["errors"].empty?
      save_employee @employees["employees_save"]
      update_employee @employees["employees_update"]
      redirect_to employees_path
    end

    file.remove!
  end

  def report
    @classification_headings = ClassificationHeading.order('display_order')
    if params[:report_type]
      @company = Company.first
      @report_type = params[:report_type]
      @report_type_change = params[:report_type].split("_").each{|word| word.capitalize!}.join(" ")
      @employees = Employee.report_data params[:report_type],params[:report][:classification]
      respond_to do |format|
        format.html # new.html.haml
        format.pdf do
          render :pdf => 'Report',
                 :handlers => [:haml],
                 :format => [:pdf],
                 :template => 'employees/report'
        end
      end
    end
  end

  def pf_contribution_restrict
    if params[:search]
      @employeesList = Employee.order('created_at ASC').search(params[:search])
    else
      @employeesList = Employee.order('created_at ASC')
    end
  end

  def pf_restrict_update
    params[:employee_data].each do |value|
      @val=Employee.find(value[:id])

      if value[:pf].nil?
        @val.update_attribute(:restrct_pf,false)
      else
        @val.update_attribute(:restrct_pf,true)
      end

      if value[:esi].nil?
        @val.update_attribute(:restrict_esi,false)
      else
        @val.update_attribute(:restrict_esi,true)
      end
    end
    redirect_to pf_contribution_restrict_employees_path
  end

  def generate_sample_excel_template

    respond_to do |format|
      format.xls do
        render :xls => 'Employee Template',
               :handlers => [:haml],
               :format => [:xls],
               :template => 'employees/generate_sample_excel_template'
      end
    end
  end


  private
    def save_employee employees
      employees.each do |employee|
        employee.save
      end
    end

    def update_employee employees
      employees.each do |employee|
        emp = Employee.find_by_refno(employee.refno)
        emp.update_attributes!(employee.attributes.except('id','refno','created_at','updated_at'))
      end
    end

  protected
    def find_employee
      @employee = Employee.find(params[:id])
    end
end
