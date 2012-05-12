class EmployeeStatutoriesController < ApplicationController

  # GET /employee_statutories/new
  # GET /employee_statutories/new.json
  def new
    @chk_pf_percentg = false
    @vpf_value = nil
    @employee = Employee.find(params[:employee_id])
    @employee_statutory =  @employee.build_employee_statutory
    @employee_id = params[:employee_id]
    @display_panoption = true
    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @employee_statutory }
    end
  end

  # GET /employee_statutories/1/edit
  def edit
    @chk_pf_percentg = false
    @vpf_value = nil
    @display_panoption = false
    @employee_id = params[:employee_id]
    @employee_statutory = EmployeeStatutory.find_by_employee_id(params[:employee_id])
    @display_panoption = true if !@employee_statutory.pan_present?
    if @employee_statutory.vol_pf
      @chk_pf_percentg = true if !@employee_statutory.vol_pf_percentage.nil?
      @employee_statutory.vol_pf_percentage.nil? ? @vpf_value = @employee_statutory.vol_pf_amount : @vpf_value = @employee_statutory.vol_pf_percentage
    end
  end

  # POST /employee_statutories
  # POST /employee_statutories.json
  def create
    @employee_statutory = EmployeeStatutory.new(params[:employee_statutory])
    @employee_statutory.pan = params[:panoption] if ( params[:employee_statutory][:pan].blank? and !params[:panoption].blank? and params[:panoption] != "ADD PAN")
    @employee_id = @employee_statutory.employee_id
    params[:chk_vol_pf_pertg] ? @employee_statutory.vol_pf_percentage = params[:vol_pf_value] : @employee_statutory.vol_pf_amount = params[:vol_pf_value]
    respond_to do |format|
      if @employee_statutory.save
        format.html { redirect_to employee_path(:id => @employee_id ), notice: 'Employee statutory was successfully created.' }
        format.json { render json: @employee_statutory, status: :created, location: @employee_statutory }
      else
        format.html { render "new" ,@employee_id => @employee_id }
        format.json { render json: @employee_statutory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /employee_statutories/1
  # PUT /employee_statutories/1.json
  def update
    params[:employee_statutory][:pan] = params[:panoption] if ( params[:employee_statutory][:pan].blank? and !params[:panoption].blank? and params[:panoption] != "ADD PAN")
    #puts params.inspect
    if params[:chk_vol_pf_pertg]
      params[:employee_statutory][:vol_pf_percentage] = params[:vol_pf_value]
      params[:employee_statutory][:vol_pf_amount] = nil
    else
      params[:employee_statutory][:vol_pf_amount] = params[:vol_pf_value]
      params[:employee_statutory][:vol_pf_percentage] = nil
    end

    @employee_statutory = EmployeeStatutory.find(params[:id])
    respond_to do |format|
      if @employee_statutory.update_attributes(params[:employee_statutory])
        @employee_statutory.update_details
        format.html { redirect_to employee_path(:id => @employee_statutory.employee_id ), notice: 'Employee statutory was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @employee_statutory.errors, status: :unprocessable_entity }
      end
    end
  end

end


