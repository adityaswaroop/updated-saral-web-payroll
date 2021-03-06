class AttendanceConfigurationsController < ApplicationController

  before_filter :find_attendance_configuration, :only => [:edit, :update, :destroy]

  def index
    @attendance_configurations = AttendanceConfiguration.where('id>1').order('created_at ASC').paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html # salary_sheet.html.haml
      format.json { render json: @attendance_configurations }
    end
  end

  def edit

  end

  def new
    @attendance_configuration = AttendanceConfiguration.new

    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @attendance_configuration }
    end
  end

  def create
    @attendance_configuration = AttendanceConfiguration.new(params[:attendance_configuration])

    respond_to do |format|
      if @attendance_configuration.save
        format.html { redirect_to attendance_configurations_url, notice: 'Attendance configuration was successfully created.' }
        format.json { render json: @attendance_configuration, status: :created, location: @attendance_configuration }
      else
        format.html { render 'new' }
        format.json { render json: @attendance_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @attendance_configuration.update_attributes(params[:attendance_configuration])
        format.html { redirect_to attendance_configurations_url, notice: 'Attendance configuration was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render 'edit' }
        format.json { render json: @attendance_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      @attendance_configuration.destroy
      flash[:success] = "Successfully destroyed."
    rescue ActiveRecord::DeleteRestrictionError => e
      @attendance_configuration.errors.add(:base, e)
      flash[:error] = "Selected Attendance Configuration is being used. Not allow to delete."
    ensure
      respond_to do |format|
        format.html { redirect_to attendance_configurations_url }
        format.json { head :ok }
      end
    end

  end

  protected
    def find_attendance_configuration
      @attendance_configuration = AttendanceConfiguration.find(params[:id])
    end
end
