class SalaryGroupDetailsController < ApplicationController

  before_filter :param_salary_grp_id, :only => [:index, :show, :new, :edit]
  before_filter :find_salary_group_detail, :only => [:update, :destroy]

  def index
    if @param_sal_grp_id
      @salary_group_details = SalaryGroupDetail.all_salary_group_details(@param_sal_grp_id).paginate(:page => params[:page], :per_page => 10)
    else
      @salary_group_details = SalaryGroupDetail.order('created_at ASC').paginate(:page => params[:page], :per_page => 10)
    end

    respond_to do |format|
      format.html # salary_sheet.html.haml
      format.json { render json: @salary_group_details }
    end
  end

  def show
    @salary_group_detail = SalaryGroupDetail.find(params[:id])
    @previous_salary_group_details = SalaryGroupDetail.previous_salary_grp_details @salary_group_detail.salary_group_id, @salary_group_detail.salary_head_id

    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @salary_group_detail }
    end
  end

  def new
    @salary_group_detail = SalaryGroupDetail.new

    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @salary_group_detail }
    end
  end

  def edit
    @salary_group_detail = SalaryGroupDetail.find(params[:id])
  end

  def create
    @salary_group_detail = SalaryGroupDetail.new(params[:salary_group_detail])
    emp_detls =  EmployeeDetail.find_all_by_salary_group_id(@salary_group_detail.salary_group_id)
    #emp_detls.each do |emp_det|
    #  puts emp_det.id
    #end
    respond_to do |format|
      if emp_detls.empty?
        month_year = params[:salary_group_detail]["effective_month"]
        eff_date = Date.strptime month_year, '%b/%Y'
          if @salary_group_detail.save
            @emp_details = @salary_group_detail.salary_group.employee_details
            if @emp_details
              @emp_details.each do |emp_det|
                SalaryAllotment.create!(:employee_id => emp_det.employee_id, :employee_detail_id => emp_det.id, :effective_date => eff_date.beginning_of_month, :salary_head_id => @salary_group_detail.salary_head_id, :salary_group_detail_id => @salary_group_detail.id, :salary_allotment =>0)
              end
            end
            format.html { redirect_to salary_group_details_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary group detail was successfully created.' }
          else
            format.html { redirect_to new_salary_group_detail_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary Head has already been taken' }
          end
      else
        format.html { redirect_to new_salary_group_detail_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary Group is already assigned' }
      end
    end
  end

  def update
    effective_month_existence = SalaryGroupDetail.chk_effective_month params[:salary_group_detail]["effective_month"],params[:id]
    if effective_month_existence.empty?
      emp_detls =  EmployeeDetail.find_all_by_salary_group_id(params[:salary_group_detail]["salary_group_id"])
      if emp_detls.empty?
        @salary_group_detail = SalaryGroupDetail.new(params[:salary_group_detail])
        if @salary_group_detail.save
          redirect_to salary_group_details_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary group detail was successfully created.'
        else
          redirect_to new_salary_group_detail_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary Head has already been taken'
        end
      else
        redirect_to edit_salary_group_detail_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary Group is already assigned'
      end
    else
      if @salary_group_detail.update_attributes(params[:salary_group_detail])
        if params[:salary_group_detail]["calc_type"] != "Every Month"
          paymonth_id = Paymonth.find_by_month_name(params[:salary_group_detail]["effective_month"]).id
          EveryMonthCompValue.destroy_all("paymonth_id=#{paymonth_id} and salary_group_id = #{params[:salary_group_detail]['salary_group_id']}")
        end
        redirect_to salary_group_details_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary group detail was successfully updated.'
      else
        redirect_to edit_salary_group_detail_path(:param1 => params[:salary_group_detail]['salary_group_id'])
      end
    end
  end

  def destroy
    param1 = @salary_group_detail.salary_group_id
    begin
      @salary_group_detail.destroy
      flash[:success] = "Successfully detroyed."
    rescue ActiveRecord::DeleteRestrictionError => e
      @salary_group_detail.errors.add(:base, e)
      flash[:error] = "Selected head is already assigned to employee. Not allow to delete."
    ensure
      respond_to do |format|
        format.html { redirect_to salary_group_details_path(:param1 => param1) }
        format.json { head :ok }
      end
    end
  end

  def group_details
    complex_sal_grp_id = params[:salary_head_n_grp_ids]
    ids = complex_sal_grp_id.split("-")
    salary_group_detail = SalaryGroupDetail.where("salary_head_id = ? and salary_group_id = ?", ids[0], ids[1]).order("created_at DESC").first

    if salary_group_detail
      @salary_group_detail = salary_group_detail
    else
      @salary_group_detail = SalaryGroupDetail.new(:salary_head_id => ids[0], :salary_group_id => ids[1])
    end
    respond_to do |format|
      format.js
    end
  end

  protected
    def param_salary_grp_id
      @param_sal_grp_id = params[:param1]
    end

    def find_salary_group_detail
      @salary_group_detail = SalaryGroupDetail.find(params[:id])
    end
end
