require "singleton"
class Global
  include Singleton

  def initialize
    @date_format = DateFormat.find_by_date_format(OptionSetting.first.date_format).date_format_value
  end

  def date_format_type
    @date_format
  end

  def setter_date_format_type
    @date_format = DateFormat.find_by_date_format(OptionSetting.first.date_format).date_format_value
  end
end