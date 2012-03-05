class Salary < ActiveRecord::Base
  belongs_to :salary_head
  belongs_to :employee_detail

  def self.is_salary_generated? month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'
    Salary.select("effective_date").where("extract(month from effective_date) = #{month_year.month} and extract(year from effective_date) = #{month_year.year} AND employee_id = #{employee_id}").count > 0
  end

  def self.get_salary_on_salary_type  salary_type, month_year, employee_id=''
    month_year = Date.strptime month_year, '%b/%Y'

    empid = (employee_id=="")?" IS NOT NULL ":" = "+employee_id

    condition = "employee_id " + empid + " and salary_type = '" + salary_type + "' and
                  extract(month from effective_date) = #{month_year.month} and
                  extract(year from effective_date) = #{month_year.year} and salary_amount != 0"

    Salary.select('salary_head_id, sum(salary_amount) as salary_amount').
        joins(:salary_head).
        where(condition).group('salary_head_id').order('salary_head_id ASC')
  end

  def self.get_pf_amount month_year, employee_id=''
    month_year = Date.strptime month_year, '%b/%Y'

    empid = (employee_id=="")?" IS NOT NULL ":" = "+employee_id

    condition = " employee_id " + empid + " and salary_head_id = 1 and
                  extract(month from effective_date) = #{month_year.month} and
                  extract(year from effective_date) = #{month_year.year}"
    basic_amount = Salary.select('sum(salary_amount) as salary_amount').where(condition)

    condition = " employee_id " + empid + " and salary_head_id = 2 and
                  extract(month from effective_date) = #{month_year.month} and
                  extract(year from effective_date) = #{month_year.year}"
    da_amount = Salary.select('sum(salary_amount) as salary_amount').where(condition)

    pf_rate_value = PfEsiRate.last

    if((basic_amount[0]['salary_amount'] + da_amount[0]['salary_amount']) >= pf_rate_value.pf_cutoff)
      pf_amount = (pf_rate_value.pf_cutoff)*pf_rate_value.pf_rate/100
    else
      pf_amount = ((basic_amount[0]['salary_amount'] + da_amount[0]['salary_amount'])*(pf_rate_value.pf_rate/100)).round.to_f
    end
  end

  def self.get_gross_salary month_year, employee_id=''
    month_year = Date.strptime month_year, '%b/%Y'
    empid = (employee_id=="")?" IS NOT NULL ":" = "+employee_id
    condition = " employee_id  " + empid + " and salary_type = 'Earnings' and
                    extract(month from effective_date) = #{month_year.month} and
                    extract(year from effective_date) = #{month_year.year}"
    gross_salary = Salary.select('sum(salary_amount) as salary_amount').joins(:salary_head).where(condition)
    gross_salary = gross_salary[0]['salary_amount']
  end

  def self.get_esi_amount  month_year, employee_id=''
    empid = (employee_id=="")?"":employee_id
    gross_salary = get_gross_salary month_year, empid
    esi_rate_value = PfEsiRate.last

    if gross_salary < esi_rate_value.esi_cutoff
      esi_amount = (gross_salary*(esi_rate_value.esi_employee_rate/100)).round.to_f
    else
      esi_amount = nil
    end
  end

  def self.get_pt_amount month_year, employee_id=''
    empid = (employee_id=="")?"":employee_id
    gross_salary = get_gross_salary month_year, empid
    month_year = Date.strptime month_year, '%b/%Y'

    pt_amount = PtRate.select('pt').joins(:paymonth).where("to_date <= '#{month_year.end_of_month}' and min_sal_range = (select max(min_sal_range) from pt_rates where min_sal_range < #{gross_salary.to_i})")

    if pt_amount.count > 0
      get_pt = pt_amount[0]['pt']
    else
      get_pt = nil
    end

  end

  def self.find_employees_leave from_date, to_date, employee_id=''
    empid = (employee_id=="")?" IS NOT NULL ":" = "+employee_id
    LeaveDetail.select("count(employee_id) as leave_count").where("employee_id  #{empid} and leave_date between '#{from_date}' and '#{to_date}'" )
  end
end