class LeaveTakensController < ApplicationController
  # GET /leave_takens
  # GET /leave_takens.json
  def index
    @leave_takens = LeaveTaken.order('leave_detail_date desc').paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @leave_takens }
    end
  end

  # GET /leave_takens/1
  # GET /leave_takens/1.json
  #def show
  #  @leave_taken = LeaveTaken.find(params[:id])
  #
  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.json { render json: @leave_taken }
  #  end
  #end

  # GET /leave_takens/new
  # GET /leave_takens/new.json
  def new
    @leave_taken = LeaveTaken.new
    @employee_count = 0
    @leave_detail_date = ''
    p params
    if !params[:leave_detail_date].blank? and params[:show_emp_list] == "true"
      @leave_taken_employees = Employee.employee_list params[:leave_detail_date]
      @employee_count = @leave_taken_employees.count
    else
      @leave_detail_date = Global.instance.paymonth_default_month
    end
    respond_to do |format|
      format.html
      format.json { render json: @leave_taken }
    end
  end

  # GET /leave_takens/1/edit
  #def edit
  #  @leave_taken = LeaveTaken.find(params[:id])
  #end

  # POST /leave_takens
  # POST /leave_takens.json
  def create
    LeaveTaken.save_leaves params[:leave_takens],params[:leave_taken][:leave_detail_date]
    respond_to do |format|
      format.html { redirect_to leave_takens_path, notice: 'Leave Details successfully created.' }
    end
    #respond_to do |format|
    #  if @leave_taken.save
    #    format.html { redirect_to leave_takens_path, notice: 'Leave taken was successfully created.' }
    #    format.json { render json: @leave_taken, status: :created, location: @leave_taken }
    #  else
    #    format.html { render action: "new" }
    #    format.json { render json: @leave_taken.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # PUT /leave_takens/1
  # PUT /leave_takens/1.json
  #def update
  #  @leave_taken = LeaveTaken.find(params[:id])
  #
  #  respond_to do |format|
  #    if @leave_taken.update_attributes(params[:leave_taken])
  #      format.html { redirect_to leave_takens_path, notice: 'Leave taken was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: "edit" }
  #      format.json { render json: @leave_taken.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /leave_takens/1
  # DELETE /leave_takens/1.json
  def destroy
    @leave_taken = LeaveTaken.find(params[:id])
    @leave_taken.destroy

    respond_to do |format|
      format.html { redirect_to leave_takens_url }
      format.json { head :no_content }
    end
  end

  def upload

  end

  def upload_parse_validate
    excel_file = params[:excel_file]
    file = FileUploader.new
    file.store!(excel_file)
    book = Spreadsheet.open "#{file.store_path}"
    sheet1 = book.worksheet 0
    @leaves = LeaveTaken.process_leaves_excel_sheet sheet1
    file.remove!
  end

  def save
    params[:leaves_takens].each do |leave|
      LeaveTaken.create(leave)
    end
    redirect_to leave_takens_path
  end

  def generate_sample_excel_template
    respond_to do |format|
      format.xls do
        render :xls => 'Leaves Template',
               :handlers => [:haml],
               :format => [:xls],
               :template => 'leave_takens/generate_sample_excel_template'
      end
    end
  end



end
