class Salary < ActiveRecord::Base
  attr_accessible :effective_date, :salary_amount,:employee_id,:employee_detail_id,:salary_head_id,:salary_group_detail_id, :actual_salary_amount
  acts_as_audited

  belongs_to :salary_head
  belongs_to :employee_detail
  belongs_to :salary_group_detail

  delegate :head_name, :short_name, :salary_type, :to => :salary_head, :prefix => true

  def self.is_salary_generated? month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'
    Salary.select("effective_date").where("extract(month from effective_date) = #{month_year.month} and extract(year from effective_date) = #{month_year.year} AND employee_id = #{employee_id}").count > 0
  end

  def self.get_salary_on_salary_type  salary_type, month_year, employee_id, with_zero_val=0
    month_year = Date.strptime month_year, '%b/%Y'
    zero_salary_amount = (with_zero_val==0)?" and salary_amount != 0":""

    condition = "salaries.employee_id = " + employee_id + " and salary_type = '" + salary_type + "' and
                  extract(month from effective_date) = #{month_year.month} and
                  extract(year from effective_date) = #{month_year.year} #{zero_salary_amount}"

    Salary.select('salaries.salary_head_id, sum(salary_amount) as salary_amount,salaries.salary_group_detail_id,print_name,print_order').joins(:salary_head).joins('LEFT OUTER JOIN "salary_group_details" ON "salary_group_details"."salary_head_id" = "salaries"."salary_head_id"').where(condition).group('salaries.salary_head_id, print_name, print_order, salaries.id, salary_group_details.id').order('print_order ASC')
  end

  def self.get_pf_amount month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'

    employee_branch = EmployeeDetail.employee_branch month_year,employee_id
    employee_pf_group = Branch.find(employee_branch[0]['branch_id']).pf_group_id
    pf_effective_date_detail = PfDetail.effective_date employee_branch[0]['branch_id'],employee_pf_group

    if pf_effective_date_detail.empty?
      pf_amount = 0
    else
      pf_effective_date = pf_effective_date_detail[0]['pf_effective_date']
      if pf_effective_date <= month_year.beginning_of_month
        pf_rate_value = PfGroupRate.pf_rate month_year,employee_pf_group

        pf_applicable_salary_amount = Salary.select('salary_amount').joins(:salary_group_detail).where("pf_applicability = true and employee_id = #{employee_id} and effective_date = '#{month_year.beginning_of_month}'")

        @pf_applicable_sal = 0
        pf_applicable_salary_amount.each do |pf_appli_sal|
           @pf_applicable_sal = @pf_applicable_sal+pf_appli_sal.salary_amount
        end

        if @pf_applicable_sal >= pf_rate_value[0]['cutoff']
          pf_amount = (pf_rate_value[0]['cutoff'])*pf_rate_value[0]['epf']/100
          epf_amount = (pf_rate_value[0]['cutoff'])*pf_rate_value[0]['employer_epf']/100
          eps_amount = ((EmployeeStatutory.zero_pension employee_id).empty?)?((pf_rate_value[0]['cutoff'])*pf_rate_value[0]['pension_fund']/100):0
        else
          pf_amount = (@pf_applicable_sal)*(pf_rate_value[0]['epf']/100)
          epf_amount = (@pf_applicable_sal)*pf_rate_value[0]['employer_epf']/100
          eps_amount = ((EmployeeStatutory.zero_pension employee_id).empty?)?((@pf_applicable_sal)*pf_rate_value[0]['pension_fund']/100):0
        end

        vol_pf_amount = EmployeeStatutory.get_vol_pf_amount employee_id, @pf_applicable_sal

        PfCalculatedValue.create :pf_earning => @pf_applicable_sal, :pf_amount => pf_amount, :epf_amount => epf_amount, :eps_amount => eps_amount,:vol_pf_amount => vol_pf_amount,:employee_id => employee_id,:effective_date => month_year.beginning_of_month
      else
        pf_amount = 0
      end
    end
    pf_amount
  end

  def self.get_esi_amount  month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'

    employee_branch = EmployeeDetail.employee_branch month_year,employee_id
    employee_esi_group = Branch.find(employee_branch[0]['branch_id']).esi_group_id
    esi_effective_date_detail = EsiDetail.effective_date employee_branch[0]['branch_id'],employee_esi_group

    if esi_effective_date_detail.empty?
      esi_amount = 0
    else
      esi_effective_date = esi_effective_date_detail[0]['esi_effective_date']
      if esi_effective_date <= month_year.beginning_of_month
        esi_applicable_salary = SalaryAllotment.select('salary_allotment').joins(:salary_group_detail).where("esi_applicability = true and employee_id = #{employee_id} and effective_date = '#{month_year.beginning_of_month}'")

        if esi_applicable_salary.count > 0
          esi_applicable_salary_amount = esi_applicable_salary
        else
          esi_applicable_salary_amount = SalaryAllotment.select('salary_allotment').joins(:salary_group_detail).where("esi_applicability = true and employee_id = #{employee_id} and effective_date = (select MAX(effective_date) from salary_allotments where employee_id = #{employee_id})")
        end

        @esi_applicable_sal = 0
        esi_applicable_salary_amount.each do |esi_appli_sal|
          @esi_applicable_sal = @esi_applicable_sal+esi_appli_sal.salary_allotment
        end

        esi_rate_value = EsiGroupRate.find_by_esi_group_id(employee_esi_group)
        if @esi_applicable_sal <= esi_rate_value[:cut_off]
          esi_amount = @esi_applicable_sal*(esi_rate_value[:employee_rate]/100)
          esi_employer_amount = @esi_applicable_sal*(esi_rate_value[:employer_rate]/100)
          EsiCalculatedValue.create :esi_gross => @esi_applicable_sal, :esi_amount => esi_amount, :esi_employer_amount => esi_employer_amount,:employee_id => employee_id,:effective_date => month_year.beginning_of_month
        else
          esi_amount = 0
        end
      else
        esi_amount = 0
      end
    end
    esi_amount
  end

  def self.get_pt_amount month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'

    employee_branch = EmployeeDetail.employee_branch month_year,employee_id
    employee_pt_group = Branch.find(employee_branch[0]['branch_id']).pt_group_id
    pt_effective_date_detail = PtDetail.effective_date employee_branch[0]['branch_id'],employee_pt_group
    if pt_effective_date_detail.empty?
      pt_amount = 0
    else
      pt_effective_date = pt_effective_date_detail[0]['pt_effective_date']
      if pt_effective_date <= month_year.beginning_of_month
        pt_applicable_salary_amount = Salary.select('salary_amount').joins(:salary_group_detail).where("pt_applicability = true and employee_id = #{employee_id} and effective_date = '#{month_year.beginning_of_month}'")

        @pt_applicable_sal = 0
        pt_applicable_salary_amount.each do |pt_appli_sal|
          @pt_applicable_sal = @pt_applicable_sal+pt_appli_sal.salary_amount
        end

        pt_amount_detail = PtRate.select('pt').joins(:paymonth).where("to_date <= '#{month_year.end_of_month}' and min_sal_range = (select max(min_sal_range) from pt_rates where min_sal_range < #{@pt_applicable_sal.to_i})")

        if pt_amount_detail.count > 0
          pt_amount = pt_amount_detail[0]['pt']
        else
          pt_amount = 0
        end
      else
        pt_amount = 0
      end
    end
  end

  def self.find_employees_leave from_date, to_date, employee_id
    LeaveDetail.where("employee_id = #{employee_id} and leave_date between '#{from_date}' and '#{to_date}'" ).count
  end

  def self.calculate_salary salary, pay_month
    month_year = Date.strptime pay_month, '%b/%Y'
    leave_count = Salary.find_employees_leave month_year.beginning_of_month, month_year.end_of_month ,salary[0]['employee_id']
    no_of_day_in_selected_month = Paymonth.select('number_of_days').where("to_date = '#{month_year.end_of_month}'")
    no_of_day_in_selected_month = no_of_day_in_selected_month[0]['number_of_days'].to_i
    employee_dol = Employee.chk_dol salary[0]['employee_id']
    if employee_dol
      no_of_day_if_dol_exist = employee_dol.day
      @no_of_present_days = no_of_day_if_dol_exist - leave_count
    else
      @no_of_present_days = no_of_day_in_selected_month - leave_count
    end

    salary.each do |sal|
      updated_salary_amount = (sal[:salary_amount].to_i * @no_of_present_days / no_of_day_in_selected_month).round.to_f
      updated_actual_salary_amount = sal[:salary_amount].to_i * @no_of_present_days / no_of_day_in_selected_month
      Salary.create :effective_date => sal[:effective_date], :employee_detail_id => sal[:employee_detail_id], :employee_id => sal[:employee_id], :salary_amount => updated_salary_amount, :salary_head_id => sal[:salary_head_id], :salary_group_detail_id => sal[:salary_group_detail_id], :actual_salary_amount => updated_actual_salary_amount
    end

    actual_pf_amount = get_pf_amount pay_month,salary[0]['employee_id']
    pf_amount = actual_pf_amount.round.to_f
    Salary.create(:effective_date => salary[0]['effective_date'], :employee_detail_id => salary[0]['employee_detail_id'], :employee_id => salary[0]['employee_id'], :salary_amount => pf_amount, :salary_head_id => 2, :salary_group_detail_id => nil, :actual_salary_amount => actual_pf_amount)

    actual_esi_amount = get_esi_amount pay_month,salary[0]['employee_id']
    esi_amount = actual_esi_amount.round.to_f
    Salary.create(:effective_date => salary[0]['effective_date'], :employee_detail_id =>salary[0]['employee_detail_id'], :employee_id => salary[0]['employee_id'], :salary_amount => esi_amount, :salary_head_id => 3, :salary_group_detail_id => nil, :actual_salary_amount => actual_esi_amount)

    @no_of_present_days
  end

  def self.salary_sheet month_year
    month_year_format = Date.strptime month_year, '%b/%Y'
    employee_list = Employee.employees_list month_year_format

    employee_salary_detail = []
    i=0
    employee_list.each do |emp_salary_data|
      leave_count = find_employees_leave month_year_format.beginning_of_month, month_year_format.end_of_month,emp_salary_data.id.to_s
      no_of_day_in_selected_month = Paymonth.select('number_of_days').where("to_date = '#{month_year_format.end_of_month}'")
      no_of_day_in_selected_month = no_of_day_in_selected_month[0]['number_of_days'].to_i

      employee_dol = Employee.chk_dol emp_salary_data.id
      if employee_dol
        no_of_day_if_dol_exist = employee_dol.day
        no_of_present_days = no_of_day_if_dol_exist - leave_count
      else
        no_of_present_days = no_of_day_in_selected_month - leave_count
      end

      salary_earning = get_salary_on_salary_type "Earnings", month_year,emp_salary_data.id.to_s,1
      salary_deduction = get_salary_on_salary_type "Deductions", month_year,emp_salary_data.id.to_s,1
      pt_amount = get_pt_amount month_year,emp_salary_data.id.to_s

      vol_pf_amount = PfCalculatedValue.vol_pf_amount month_year, emp_salary_data.id.to_s

      employee_salary_detail[i] = [:refno=>emp_salary_data.refno,:empname=>emp_salary_data.empname,:paid_days=>no_of_present_days,:salary_earnings=>salary_earning,:pt=>pt_amount,:vol_pf=>vol_pf_amount,:salary_deductions=>salary_deduction]
      i=i+1
    end

    employee_salary_detail
  end

  def self.salary_total month_year
    month_year_format = Date.strptime month_year, '%b/%Y'
    salary_earning_total = Salary.select("salary_heads.id,sum(salary_amount) as salary_amount").joins(:salary_head).where("effective_date='#{month_year_format.beginning_of_month}' and salary_type = 'Earnings'").group("salary_heads.id").order("salary_heads.id ASC")

    salary_deduction_total = Salary.select("salary_heads.id,sum(salary_amount) as salary_amount").joins(:salary_head).where("effective_date='#{month_year_format.beginning_of_month}' and salary_type = 'Deductions'").group("salary_heads.id").order("salary_heads.id ASC")

    employee_salary_total = [:salary_earnings_total=>salary_earning_total,:salary_deductions_total=>salary_deduction_total]
  end

end