require "singleton"
class Global
  include Singleton

  def initialize
    @date_format = DateFormat.find_by_date_format(OptionSetting.first.date_format).date_format_value
    pay_month_det = Paymonth.select('id,month_name').where('default_month = true')
    @default_month = pay_month_det[0]['month_name']
  end

  def paymonth_default_month
    @default_month
  end

  def date_format_type
    @date_format
  end

  def setter_date_format_type
    @date_format = DateFormat.find_by_date_format(OptionSetting.first.date_format).date_format_value
  end

  def setter_paymonth_default_month
    pay_month_det = Paymonth.select('id,month_name').where('default_month = true')
    @default_month = pay_month_det[0]['month_name']
  end
end