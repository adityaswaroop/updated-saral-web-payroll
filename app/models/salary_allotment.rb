class SalaryAllotment < ActiveRecord::Base
  attr_accessible :id,:employee_id, :employee_detail_id,:effective_date,:salary_head_id,:salary_allotment,:salary_group_detail_id, :created_at,:updated_at
  acts_as_audited

  belongs_to :salary_head
  belongs_to :employee
  belongs_to :employee_detail
  belongs_to :salary_group_detail

  delegate :head_name, :short_name, :salary_type, :to => :salary_head, :prefix => true

  def salaryHead
    SalaryHead.find(salary_head_id).head_name
  end

  def shortName
    SalaryHead.find(salary_head_id).short_name
  end

  def salaryHeadType
    SalaryHead.find(salary_head_id).salary_type
  end

  def generation_formula
    basic_formula = self.salary_group_detail.calculation
    basic_formula.gsub!(/\(/,'( ')
    basic_formula.gsub!(/\)/,' )')
    arrFormula = basic_formula.split(" ")
    new_arr = arrFormula.grep /[A-Za-z]{2,6}/
    new_arr.each do |node|
      salHead = SalaryHead.find_by_short_name(node)
      if salHead
        salGrpdet = SalaryGroupDetail.find_by_salary_head_id_and_salary_group_id(salHead.id,self.employee_detail.salary_group_id)
        if salGrpdet.calc_type == 'Formula'
          basic_formula["#{node}"] = "(#{salGrpdet.calculation})"
        else
          basic_formula["#{node}"] = "0"
        end
      end
    end
    basic_formula
  end

  def self.get_allotted_salaries month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'
    SalaryAllotment.where("extract(month from effective_date) = #{month_year.month} and extract(year from effective_date) = #{month_year.year} AND employee_id = #{employee_id}").order("salary_head_id ASC")
  end

  def self.get_allotted_salaries_for_max_effective_date month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'
    SalaryAllotment.select("id, employee_id, employee_detail_id,date_trunc('month', date('#{month_year.year}-#{month_year.month}-01')) as effective_date, salary_head_id, salary_allotment, salary_group_detail_id").where("employee_id = #{employee_id} and effective_date = (select MAX(effective_date) from salary_allotments where employee_id = #{employee_id})").order("salary_head_id ASC")
  end

  def self.row_for_salary_allotment employee_id
    SalaryAllotment.where("employee_id = #{employee_id} and effective_date = (select MAX(effective_date) from salary_allotments where employee_id = #{employee_id})").order('salary_head_id ASC')
  end

  def self.process_salary_excel_sheet salary_rate_sheet
    sal_allotments = Hash.new
    sal_allotments["salary_allotments"] = []
    sal_allotments["errors"] = Hash.new
    errors = Hash.new
    counter = 0

    excel_first_row = salary_rate_sheet.first

    if duplicates_in_salary_heads? excel_first_row
      errors["#{counter+1}"] = ["Duplication of salary head"]
    else
      salary_rate_sheet.each 1 do |row|
        counter += 1
        emp = Employee.find_by_refno(row[0].to_s)
        local_error = []
        emp.employee_details.first.salary_group.salary_group_details.each do |sal_grp_det|
          sal_head = sal_grp_det.salary_head
          if (excel_first_row.include? sal_head.short_name) && (!row[excel_first_row.index(sal_head.short_name)].nil?)
            sal_allot = SalaryAllotment.new
            sal_allot.employee_id = emp[:id]
            sal_allot.employee_detail_id = emp.employee_details.first[:id]
            sal_allot.effective_date = row[2]
            sal_allot.salary_head_id = sal_head.id
            sal_allot.salary_allotment = row[excel_first_row.index(sal_head.short_name)]
            sal_allotments["salary_allotments"] << sal_allot
          else
            local_error << "No allotment for #{sal_head.short_name} of employee id : #{emp[:refno]}"
          end
        end
        errors["#{counter+1}"] = local_error if local_error.length > 0
      end
    end
    sal_allotments["errors"] = errors
    sal_allotments
  end

  def self.duplicates_in_salary_heads? sal_heads
    sal_heads.size != sal_heads.uniq.size ? true : false
  end

  def self.update_salary_allotments sal_allots
    sal_allots.each do |sal_allot|
      sal_allotment = SalaryAllotment.find_by_employee_id_and_employee_detail_id_and_effective_date_and_salary_head_id(sal_allot.employee_id, sal_allot.employee_detail_id, sal_allot.effective_date, sal_allot.salary_head_id)
      #sal_allotment = SalaryAllotment.row_for_salary_allotment sal_allot.employee_id
      #puts sal_allotment.inspect
      sal_allotment.update_attributes(:salary_allotment => sal_allot.salary_allotment)
    end
  end

end