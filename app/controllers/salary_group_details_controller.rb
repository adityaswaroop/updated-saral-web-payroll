class SalaryGroupDetailsController < ApplicationController

  before_filter :param_salary_grp_id, :only => [:index, :show, :new, :edit]
  before_filter :find_salary_group_detail, :only => [:update, :destroy]

  def index
    if @param_sal_grp_id
      @salary_group_details = SalaryGroupDetail.where(:salary_group_id=>@param_sal_grp_id).order('created_at ASC').paginate(:page => params[:page], :per_page => 10)
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

    respond_to do |format|
      if @salary_group_detail.save
        format.html { redirect_to salary_group_details_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary group detail was successfully created.' }
        format.json { render json: @salary_group_detail, status: :created, location: @salary_group_detail }
      else
        format.html { redirect_to new_salary_group_detail_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary Head has already been taken' }
        format.json { render json: @salary_group_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @salary_group_detail.update_attributes(params[:salary_group_detail])
        format.html{ redirect_to salary_group_details_path(:param1 => params[:salary_group_detail]['salary_group_id']), notice: 'Salary group detail was successfully updated.' }
        format.json { head :ok }
      else
        format.html { redirect_to edit_salary_group_detail_path(:param1 => params[:salary_group_detail]['salary_group_id'])}
        format.json { render json: @salary_group_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @salary_group_detail.destroy

    respond_to do |format|
      format.html { redirect_to salary_group_details_path }
      format.json { head :ok }
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
