class LeaveTaken < ActiveRecord::Base
  attr_accessible :employee_id, :leave_from_date, :leave_count, :lop_count,:leave_detail_date,:leave_to_date,:lop_from_date,:lop_to_date
  acts_as_audited

  belongs_to :employee, :validate => true
  #validates_presence_of :from_date, :employee_id , :count
  #validates_presence_of :employee, :message => " does not exists."

  #def set_to_date
  #  Date.strptime(from_date.to_s,"%Y-%m-%d")+count
  #end

  def self.process_leaves_excel_sheet leave_excel_sheet
    leaves_takens = Hash.new
    leaves_takens["leaves_takens"] = []
    leaves_takens["errors"] = Hash.new
    errors = Hash.new
    counter = 0

    excel_first_row = leave_excel_sheet.first

    if duplicates_in_leave_columns? excel_first_row
      errors["#{counter+1}"] = ["Duplication of leave columns"]
    else
      leave_excel_sheet.each 1 do |row|
        counter+=1
        liv = LeaveTaken.new
        liv.employee_id = Employee.find_by_refno("#{row[0]}").id
        liv.leave_detail_date = row[1].beginning_of_month
        liv.leave_count = row[2]
        liv.leave_from_date = row[3]
        liv.leave_to_date = row[4]
        liv.lop_count = row[5]
        liv.lop_from_date = row[6]
        liv.lop_to_date = row[7]
        leaves_takens["leaves_takens"] << liv
      end
    end
    leaves_takens["errors"] = errors
    leaves_takens
  end

  def self.duplicates_in_leave_columns? leave_columns
    leave_columns.size != leave_columns.uniq.size ? true : false
  end



  def month_year
    (Date.strptime leave_detail_date, "%Y-%m-%d").strftime("%b/%Y")
  end

  def employee_name
    Employee.find(employee_id).empname
  end

  def self.save_leaves leave_takens,paymonth
    pay_month = Date.strptime paymonth, "%b/%Y"
    pay_month = pay_month.beginning_of_month
    leave_taken = []
    if !leave_takens.nil?
      leave_takens.each do |leave|
        if !leave[1]["leave_count"].blank? or !leave[1]["lop_count"].blank?
          leave[1]["leave_count"] = 0 if(leave[1]["leave_count"].nil? or leave[1]["leave_count"].blank?)
          leave[1]["lop_count"] = 0 if(leave[1]["lop_count"].nil? or leave[1]["lop_count"].blank?)

          date_format=OptionSetting.date_format_value
          if date_format == "%m-%Y-%d" || date_format == "%m/%d/%Y" || date_format == "%d/%m/%y" || date_format == "%d-%m-%y"
            dates_value=[leave[1]["leave_from_date"],leave[1]["leave_to_date"],leave[1]["lop_from_date"],leave[1]["lop_to_date"]]
            dates=OptionSetting.convert_date(dates_value)
            leave_taken = {:employee_id => leave[1]["employee_id"],:leave_from_date=>dates[0],:leave_detail_date=>pay_month,:leave_to_date=>dates[1],:lop_from_date=>dates[2],:lop_to_date=>dates[3],:lop_count=>leave[1]["lop_count"],:leave_count=>leave[1]["leave_count"]}
          else
            leave_taken = {:employee_id => leave[1]["employee_id"],:leave_from_date=>leave[1]["leave_from_date"],:leave_detail_date=>pay_month,:leave_to_date=>leave[1]["leave_to_date"],:lop_from_date=>leave[1]["lop_from_date"],:lop_to_date=>leave[1]["lop_to_date"],:lop_count=>leave[1]["lop_count"],:leave_count=>leave[1]["leave_count"]}
          end
          LeaveTaken.create(leave_taken)
        end
      end
    end
  end

end