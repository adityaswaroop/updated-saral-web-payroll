class OptionSettingsController < ApplicationController

  def index
    @option_setting = OptionSetting.first

    respond_to do |format|
      format.html # index.html.haml
      format.json { render json: @option_setting }
    end
  end

  def edit
    @option_setting = OptionSetting.find(params[:id])

    if params[:option_setting]
      @currency = Country.find(params[:option_setting]["country_id"]).currency
    else
      @currency = @option_setting.currency
    end
  end

  def update
    @option_setting = OptionSetting.find(params[:id])

    respond_to do |format|
      if @option_setting.update_attributes(params[:option_setting])
        glb = Global.instance
        glb.setter_date_format_type

        format.html { redirect_to edit_option_setting_path(@option_setting), notice: 'Option setting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @option_setting.errors, status: :unprocessable_entity }
      end
    end
  end

end
