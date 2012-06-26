class PaymonthsController < ApplicationController

  def index
    @paymonths = Paymonth.order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    @count = @paymonths.count
  end

  def new
    @paymonth = Paymonth.new
    com_start_month = OptionSetting.first.salary_calc
    Paymonth.count > 0 ? @next_month = Paymonth.next_paymonth : @next_month = com_start_month
  end

  def show
    @paymonth = Paymonth.find(params[:id])
    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @employee }
    end
  end

  def create
    tmp_month_year = params[:paymonth][:month_name]
    if Paymonth.new(:month_name => tmp_month_year).valid?
      res =  Paymonth.proceed_to_save tmp_month_year
      if res[0]
        params_to_save = Paymonth.find_month_details_to_save tmp_month_year
        @paymonth = Paymonth.new(:month_year => params_to_save[0],:number_of_days => params_to_save[1],:from_date => params_to_save[2],:to_date => params_to_save[3],:month_name => params_to_save[4])
        respond_to do |format|
          if @paymonth.save
            @paymonth.update_default_month
            format.html {redirect_to paymonths_url, notice: 'Paymonth was successfully created.' }
            format.json { render json: @paymonth, status: :created, location: @paymonth }
          else
            format.html { render 'new' }
            format.json { render json: @paymonth.errors, status: :unprocessable_entity }
          end
        end
      else
        @paymonth = Paymonth.new
        @paymonth.errors.add(:paymonth, "Out of sequence Month/Year can not be created. Next Month to be created is #{res[1]}")
        respond_to do |format|
          format.html { render 'new'}
        end
      end
    else
      @paymonth = Paymonth.new
      @paymonth.errors.add(:paymonth, "is invalid.")
      respond_to do |format|
        format.html { render 'new' }
      end
    end
  end

  def save
    @paymonth = Paymonth.new
    @paymonth.update_paymonths params[:paymonth]
    respond_to do |format|
      format.html { redirect_to paymonths_url, notice: "Paymonths updated successfully." }
    end
  end

  def destroy
    first_paymonth = Paymonth.first
    last_paymonth = Paymonth.last

    @paymonth = Paymonth.find(params[:id])

    if( @paymonth.id == first_paymonth.id or @paymonth.id == last_paymonth.id )
      begin
        @paymonth.destroy
        @paymonth.latest_mon_as_default_month
        flash[:notice] = "Successfully destroyed."
      rescue ActiveRecord::DeleteRestrictionError => e
        @paymonth.errors.add(:base, e)
        flash[:error] = "Paymonth is being used. Not allow to delete."
      ensure
        respond_to do |format|
          format.html { redirect_to paymonths_url}
          format.json { head :ok }
        end
      end
    else
      respond_to do |format|
        @paymonth.errors.add(:paymonth, "Out of sequence. Month/Year can not be deleted.")
        format.html { redirect_to paymonths_url, notice: "Out of sequence Month/Year can not be deleted." }
      end
    end
  end
end
