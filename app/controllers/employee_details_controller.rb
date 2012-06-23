class EmployeeDetailsController < ApplicationController
  # GET /employee_details
  # GET /employee_details.json
  require 'will_paginate/array'

  def index
    @classification_headings = ClassificationHeading.order('display_order')
    @paramempid = params[:param1]
    if @paramempid
      @employee_details = EmployeeDetail.where(:employee_id=>@paramempid).order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    else
      @employee_details = EmployeeDetail.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    end

    respond_to do |format|
      format.html # salary_sheet.html.haml
      format.json { render json: @employee_details }
    end
  end

  # GET /employee_details/1
  # GET /employee_deta  ils/1.json
  def show
    @paramempid = params[:param1]
    @employee_detail = EmployeeDetail.find(params[:id])
    @classification_headings = ClassificationHeading.order('display_order')
    @edit_yn = params[:edit_yn]
    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @employee_detail }
    end
  end

  # GET /employee_details/new
  # GET /employee_details/new.json
  def new
    @classification_headings = ClassificationHeading.order('display_order')
    @paramempid = params[:param1]
    @employee_detail = EmployeeDetail.new()
    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @employee_detail }
    end
  end

  # GET /employee_details/1/edit
  def edit
    @paramempid = params[:param1]
    @employee_detail = EmployeeDetail.find(params[:id])
    @classification_headings = ClassificationHeading.order('display_order')
  end

  # POST /employee_details
  # POST /employee_details.json
  def create
    employee=params[:employee_detail]
    date_format=OptionSetting.date_format_value
    if date_format == "%m-%Y-%d" || date_format == "%m/%d/%Y" || date_format == "%d/%m/%y" || date_format == "%d-%m-%y"
      dates_value=[employee[:effective_date]]
      dates=OptionSetting.convert_date(dates_value)
      val=employee.merge!(:effective_date=>dates[0])
      @employee_detail = EmployeeDetail.new(val)
    else
      @employee_detail = EmployeeDetail.new(params[:employee_detail])
    end
    @employee_detail = EmployeeDetail.new(params[:employee_detail])
    @paramempid = @employee_detail.employee_id
    @classification_headings = ClassificationHeading.order('display_order')
    respond_to do |format|
      if @employee_detail.employee_id != nil
        if @employee_detail.save then
          @employee_detail.employee_salary_allotment
          @employee_detail.do_update_after_save
          format.html { redirect_to employee_details_path(:param1 => @employee_detail.employee_id), notice: 'Employee detail was successfully created.' }
          format.json { render json: @employee_detail, status: :created, location: @employee_detail }
        else
          format.html { render "new" }
          format.json { render json: @employee_detail.errors, status: :unprocessable_entity }
        end
      else
        format.html { render "new" }
        format.json { render json: @employee_detail.errors, status: :unprocessable_entity }

      end
    end
  end

  # PUT /employee_details/1
  # PUT /employee_details/1.json
  def update
    date_format=OptionSetting.date_format_value
    if date_format == "%m-%Y-%d" || date_format == "%m/%d/%Y" || date_format == "%d/%m/%y" || date_format == "%d-%m-%y"
      dates_value=[params[:employee_detail][:effective_date]]
      dates=OptionSetting.convert_date(dates_value)
      params[:employee_detail].merge!(:effective_date=>dates[0])
    else
      params[:employee_detail]
    end
    @employee_detail = EmployeeDetail.find(params[:id])
    @paramempid = params[:employee_detail]['employee_id']
    @classification_headings = ClassificationHeading.order('display_order')
    respond_to do |format|
      if @employee_detail.update_attributes(params[:employee_detail])
        format.html { redirect_to employee_details_path(:param1 => @paramempid), notice: 'Employee detail was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render 'edit' }
        format.json { render json: @employee_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_details/1
  # DELETE /employee_details/1.json
  def destroy
    @employee_detail = EmployeeDetail.find(params[:id])
    @paramempid = @employee_detail.employee_id
    @employee_detail.destroy
    @employee_detail.do_update_after_delete
    respond_to do |format|
      format.html { redirect_to employee_details_url(:param1 => @paramempid), notice: 'Employee detail was successfully Destroyed.' }
      format.json { head :ok }
    end
  end
end