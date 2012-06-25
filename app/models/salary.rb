class Salary < ActiveRecord::Base
  attr_accessible :effective_date, :salary_amount,:employee_id,:employee_detail_id,:salary_head_id,:salary_group_detail_id, :actual_salary_amount, :present_days, :pay_days
  acts_as_audited

  belongs_to :salary_head
  belongs_to :employee_detail
  belongs_to :salary_group_detail

  delegate :head_name, :short_name, :salary_type, :to => :salary_head, :prefix => true

  def self.salary_month
    effective_date_db = Salary.select("effective_date").uniq
    condition = ""
    effective_date_db.each do |date|
      condition += "from_date = '#{date[:effective_date]}' OR "
    end
    final_condition = condition[0..-4]
    Paymonth.where(final_condition).order("created_at DESC")
  end

  def self.is_salary_generated? month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'
    Salary.select("effective_date").where("extract(month from effective_date) = #{month_year.month} and extract(year from effective_date) = #{month_year.year} AND employee_id = #{employee_id}").count > 0
  end

  def self.get_salary_on_salary_type  salary_type, month_year, employee_id, with_zero_val=0
    month_year = Date.strptime month_year, '%b/%Y'
    zero_salary_amount = (with_zero_val==0)?" and salary_amount != 0":""
    condition = "salaries.employee_id = #{employee_id} and salary_type = '#{salary_type}' and
                  extract(month from effective_date) = #{month_year.month} and
                  extract(year from effective_date) = #{month_year.year} #{zero_salary_amount}"

    Salary.select('DISTINCT(salaries.salary_head_id), sum(salary_amount) as salary_amount,salaries.salary_group_detail_id,print_name,print_order,salary_heads.created_at,pay_days, present_days').joins(:salary_head).joins('LEFT OUTER JOIN "salary_group_details" ON "salary_group_details"."id" = "salaries"."salary_group_detail_id"').where(condition).group('salaries.salary_head_id, print_name, print_order, salaries.id, salary_group_details.id,salary_heads.created_at').order('salary_heads.created_at ASC')
  end

  def self.get_pf_amount month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'

    employee_branch = EmployeeDetail.employee_branch month_year,employee_id
    employee_pf_group = Branch.find(employee_branch[0]['branch_id']).pf_group_id
    pf_effective_date_detail = PfDetail.effective_date employee_branch[0]['branch_id'],employee_pf_group
    pf_restriction = Employee.find(employee_id).restrct_pf

    if pf_restriction == true
      pf_amount = 0
    else
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
        #esi_applicable_salary = SalaryAllotment.select('salary_allotment').joins(:salary_group_detail).where("esi_applicability = true and employee_id = #{employee_id} and effective_date = '#{month_year.beginning_of_month}'")
        #
        #if esi_applicable_salary.count > 0
        #  esi_applicable_salary_amount = esi_applicable_salary
        #else
        #  esi_applicable_salary_amount = SalaryAllotment.select('salary_allotment').joins(:salary_group_detail).where("esi_applicability = true and employee_id = #{employee_id} and effective_date = (select MAX(effective_date) from salary_allotments where employee_id = #{employee_id})")
        #end

        esi_applicable_salary_amount = Salary.select('salary_amount').joins(:salary_group_detail).where("esi_applicability = true and employee_id = #{employee_id} and effective_date = '#{month_year.beginning_of_month}'")

        @esi_applicable_sal = 0
        esi_applicable_salary_amount.each do |esi_appli_sal|
          @esi_applicable_sal = @esi_applicable_sal+esi_appli_sal.salary_amount
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

  def self.employee_salary_det_header salary_group_id, salary_type,pay_month
    month_year = Date.strptime pay_month, '%b/%Y'
    det_head = SalaryHead.select('head_name').joins(:salary_group_details).where("salary_group_id = ? and salary_type = ? and to_date(effective_month,'Mon/YYYY') <= '#{month_year.beginning_of_month}'",salary_group_id, salary_type).order("salary_heads.created_at ASC")
  end

  def self.employee_salary_detail pay_month, salary_group_id
    month_year = Date.strptime pay_month, '%b/%Y'
    valid_employee = Employee.select('DISTINCT(employees.id),employees.created_at,refno, empname').joins("INNER JOIN salaries ON employees.id = salaries.employee_id INNER JOIN salary_group_details ON salaries.salary_group_detail_id = salary_group_details.id INNER JOIN salary_groups ON salary_group_details.salary_group_id = salary_groups.id").where("(date_of_leaving IS NULL OR extract(month from date_of_leaving) = #{month_year.month} and extract(year from date_of_leaving) = #{month_year.year}) and salary_groups.id = ? and salaries.effective_date = '#{month_year.beginning_of_month}'", salary_group_id).order("employees.created_at ASC")

    if valid_employee.empty?
      employee_salary_det = []
    else
      employee_salary_det = []
      i=0
      valid_employee.each do |employee|
        salary_earning = get_salary_on_salary_type "Earnings", pay_month, employee.id,1
        salary_deduction = get_salary_on_salary_type "Deductions", pay_month, employee.id,1
        pt_amount = get_pt_amount pay_month, employee.id
        vol_pf_amount = PfCalculatedValue.calculated_vol_pf_amount pay_month, employee.id
        employee_salary_det[i] = {:id=>employee.id,:refno=>employee.refno,:empname=>employee.empname,:no_of_present_days=>salary_earning[0]["present_days"],:no_of_pay_days=>salary_earning[0]["pay_days"],:salary_earning=>salary_earning,:salary_deduction=>salary_deduction,:pt_amount=>pt_amount,:vol_pf_amount=>vol_pf_amount}
        i=i+1
      end
    end
    employee_salary_det
  end

  def self.employee_payslip pay_month, employee_id
    company_det = Company.first
    employee = Employee.find(employee_id)
    month_year = Date.strptime pay_month, '%b/%Y'
    leave_count = Salary.find_employees_leave month_year.beginning_of_month, month_year.end_of_month ,employee_id
    no_of_day_in_selected_month = Paymonth.select('number_of_days').where("to_date = '#{month_year.end_of_month}'")
    no_of_day_in_selected_month = no_of_day_in_selected_month[0]['number_of_days'].to_i

    #employee_dol = Employee.chk_dol employee_id
    #if employee_dol
    #  no_of_day_if_dol_exist = employee_dol.day
    #  @no_of_present_days = no_of_day_if_dol_exist - leave_count
    #else
    #  @no_of_present_days = no_of_day_in_selected_month - leave_count
    #end

    salary_earning = get_salary_on_salary_type "Earnings", pay_month, employee_id,0
    salary_deduction = get_salary_on_salary_type "Deductions", pay_month, employee_id,0

    pt_amount = get_pt_amount pay_month, employee_id
    vol_pf_amount = PfCalculatedValue.calculated_vol_pf_amount pay_month, employee_id

    employee_det = {:no_of_present_days=>salary_earning[0]["present_days"],:no_of_pay_days=>salary_earning[0]["pay_days"],:salary_earning=>salary_earning,:salary_deduction=>salary_deduction,:pt_amount=>pt_amount,:vol_pf_amount=>vol_pf_amount,:company=>company_det,:employee=>employee}
  end

  def self.employees_salary_calculation pay_month, salary_group_id
    month_year = Date.strptime pay_month, '%b/%Y'
    pay_month_id = Paymonth.find_by_month_name(pay_month)[:id]
    chk_salary_group_exist = SalaryGroup.select("DISTINCT(salary_groups.id), salary_group_name").joins(:employee_details).where("salary_group_id = #{salary_group_id} and effective_date <= '#{month_year.beginning_of_month}'" )

    if chk_salary_group_exist.empty?
      employee_salary_calc = []
    else
      #valid_employee = Employee.select('employees.id,refno, empname,date_of_joining,date_of_leaving').joins("INNER JOIN employee_details ON employees.id = employee_details.employee_id INNER JOIN salary_groups ON employee_details.salary_group_id = salary_groups.id").where("(date_of_leaving IS NULL OR extract(month from date_of_leaving) = #{month_year.month} and extract(year from date_of_leaving) = #{month_year.year}) and salary_groups.id = ? and (effective_to IS NULL OR effective_to = '#{month_year.end_of_month}')", salary_group_id)

<<<<<<< HEAD
      valid_employee = Employee.select('employees.id,refno, empname,date_of_joining,date_of_leaving').joins("INNER JOIN employee_details ON employees.id = employee_details.employee_id INNER JOIN salary_groups ON employee_details.salary_group_id = salary_groups.id").where("(date_of_leaving IS NULL OR extract(month from date_of_leaving) = #{month_year.month} and extract(year from date_of_leaving) = #{month_year.year}) and salary_groups.id = ?", salary_group_id)

      p valid_employee
=======
      valid_employee = Employee.select('employees.id,refno, empname,date_of_joining,date_of_leaving').joins("INNER JOIN employee_details ON employees.id = employee_details.employee_id INNER JOIN salary_groups ON employee_details.salary_group_id = salary_groups.id").where("(date_of_leaving IS NULL OR extract(month from date_of_leaving) = #{month_year.month} and extract(year from date_of_leaving) = #{month_year.year}) and salary_groups.id = ? and (('#{month_year.end_of_month}' between effective_date and effective_to OR effective_to IS NULL) and effective_date <= '#{month_year.beginning_of_month}')", salary_group_id)
>>>>>>> 2a233866d66576ecd396de110b93d04e3093c297

      employee_salary_calc = []
      i=0
      valid_employee.each do |employee|
        allotted_salaries = SalaryAllotment.get_allotted_salaries pay_month, employee.id, 1
        if allotted_salaries.count > 0
          salary_allotments = allotted_salaries
        else
          salary_allotments = SalaryAllotment.get_allotted_salaries_for_max_effective_date pay_month, employee.id, 1
        end

        every_month_comp_value = EveryMonthCompValue.select("salary_amount").where("employee_id = ? and paymonth_id = ? and salary_group_id =?",employee.id, pay_month_id, salary_group_id)

        if every_month_comp_value.empty?
          salary_allotments
        else
          j=0
          every_month_comp_value[0][:salary_amount].each do |sal_head_id, value|
            salary_allotments[j]["salary_allotment"] = value
            j=j+1
          end
        end

        employee_doj = employee.date_of_joining
        employee_dol = employee.date_of_leaving

        actual_no_of_days = get_actual_days employee_doj, employee_dol, month_year

        leave_taken = LeaveTaken.select('sum(leave_count) as leave_count, sum(lop_count) as lop_count').where("leave_detail_date = '#{month_year.beginning_of_month}' AND employee_id = #{employee.id}")
        if leave_taken.count != 0
          pay_days = actual_no_of_days - leave_taken[0][:lop_count]
          present_days = actual_no_of_days - (leave_taken[0][:lop_count]+leave_taken[0][:leave_count])
        else
          pay_days = actual_no_of_days
          present_days = actual_no_of_days
        end

        employee_salary_calc[i] = {:id=>employee.id,:refno=>employee.refno,:empname=>employee.empname,:present_days=>present_days,:pay_days=>pay_days,:salary_allotment=>salary_allotments}
        i=i+1
      end
      employee_salary_calc
    end
    employee_salary_calc
  end

  def self.get_actual_days doj, dol, month_year
    join_from = (doj.month == month_year.month && doj.year == month_year.year)?(doj.day)-1:0
    if dol.nil?
      actual_days = (month_year.end_of_month.day)-join_from
    else
      left_from = (dol.month == month_year.month && dol.year == month_year.year)?(dol.day):0
      actual_days = left_from-join_from
    end
    actual_days
  end

  def self.emp_salary_calc_header salary_group_id, pay_month
    month_year = Date.strptime pay_month, '%b/%Y'
    SalaryHead.select('DISTINCT(head_name),salary_heads.created_at').joins(:salary_group_details).where("salary_group_id = ? and calc_type = 'Every Month' and to_date(effective_month,'Mon/YYYY') <= '#{month_year.beginning_of_month}'",salary_group_id).order("salary_heads.created_at ASC")
  end

  def self.calculate_salary salaries, pay_month
    month_year = Date.strptime pay_month, '%b/%Y'
    salaries.each do |salary|
      Salary.destroy_all("employee_id = #{salary[1][0]["employee_id"]} and effective_date = '#{month_year.beginning_of_month}'")
      PfCalculatedValue.destroy_all("employee_id = #{salary[1][0]["employee_id"]} and effective_date = '#{month_year.beginning_of_month}'")
      EsiCalculatedValue.destroy_all("employee_id = #{salary[1][0]["employee_id"]} and effective_date = '#{month_year.beginning_of_month}'")
      leave_count = Salary.find_employees_leave month_year.beginning_of_month, month_year.end_of_month ,salary[1][0]["employee_id"]
      no_of_day_in_selected_month = Paymonth.select('number_of_days').where("to_date = '#{month_year.end_of_month}'")
      no_of_day_in_selected_month = no_of_day_in_selected_month[0]['number_of_days'].to_i
      no_of_present_days = salary[1][0]["present_days"]
      no_of_pay_days = salary[1][0]["pay_days"]

      ######## Salary calculation with heads which are NOT Every Month components ##########
      allotted_salaries = SalaryAllotment.get_allotted_salaries pay_month, salary[1][0]["employee_id"]
      if allotted_salaries.count > 0
        salary_allotments = allotted_salaries
      else
        salary_allotments = SalaryAllotment.get_allotted_salaries_for_max_effective_date pay_month, salary[1][0]["employee_id"]
      end

      salary_allotments.each do |sal|
        days_for_calculation = salary_calculation_days sal["salary_group_detail_id"],no_of_pay_days,no_of_present_days,no_of_day_in_selected_month

        updated_salary_amount = (sal["salary_allotment"].to_i * days_for_calculation.to_i / no_of_day_in_selected_month).round.to_f
        updated_actual_salary_amount = sal["salary_allotment"].to_i * days_for_calculation.to_i / no_of_day_in_selected_month

        Salary.create :effective_date => sal["effective_date"], :employee_detail_id => sal["employee_detail_id"], :employee_id => sal["employee_id"], :salary_amount => updated_salary_amount, :salary_head_id => sal["salary_head_id"], :salary_group_detail_id => sal["salary_group_detail_id"], :actual_salary_amount => updated_actual_salary_amount, :present_days => no_of_present_days, :pay_days => no_of_pay_days
      end
      ##########  End of Code ##########

      ##########  Salary Calculation with heads which are Every Month components ##############
      salary[1].each do |sal|
        if sal["salary_amount"]
          days_for_calculation = salary_calculation_days sal["salary_group_detail_id"],no_of_pay_days,no_of_present_days,no_of_day_in_selected_month

          updated_salary_amount = (sal["salary_amount"].to_i * days_for_calculation.to_i / no_of_day_in_selected_month).round.to_f
          updated_actual_salary_amount = sal["salary_amount"].to_i * days_for_calculation.to_i / no_of_day_in_selected_month

          Salary.create :effective_date => sal["effective_date"], :employee_detail_id => sal["employee_detail_id"], :employee_id => sal["employee_id"], :salary_amount => updated_salary_amount, :salary_head_id => sal["salary_head_id"], :salary_group_detail_id => sal["salary_group_detail_id"], :actual_salary_amount => updated_actual_salary_amount,:present_days => no_of_present_days, :pay_days => no_of_pay_days
        end
      end

      if salary_allotments.count > 0
        effective_date = salary_allotments[0]['effective_date']
      else
        effective_date = salary[1][0]["effective_date"]
      end

      actual_pf_amount = get_pf_amount pay_month,salary[1][0]["employee_id"]
      pf_amount = actual_pf_amount.round.to_f
      Salary.create(:effective_date => effective_date, :employee_detail_id => salary[1][0]['employee_detail_id'], :employee_id => salary[1][0]['employee_id'], :salary_amount => pf_amount, :salary_head_id => 2, :salary_group_detail_id => nil, :actual_salary_amount => actual_pf_amount,:present_days => no_of_present_days, :pay_days => no_of_pay_days)

      actual_esi_amount = get_esi_amount pay_month,salary[1][0]["employee_id"]
      esi_amount = actual_esi_amount.round.to_f
      Salary.create(:effective_date => effective_date, :employee_detail_id =>salary[1][0]['employee_detail_id'], :employee_id => salary[1][0]['employee_id'], :salary_amount => esi_amount, :salary_head_id => 3, :salary_group_detail_id => nil, :actual_salary_amount => actual_esi_amount,:present_days => no_of_present_days, :pay_days => no_of_pay_days)

      no_of_present_days
    end
  end

  def self.save_component_value salaries, pay_month
    pay_month_id = Paymonth.find_by_month_name(pay_month)[:id]
    salaries.each do |salary|
      salary_group_id = EmployeeDetail.find(salary[1][0]["employee_detail_id"])[:salary_group_id]
      chk_available_component_value = EveryMonthCompValue.where("employee_id = ? and paymonth_id = ? and salary_group_id =?",salary[1][0]["employee_id"],pay_month_id,salary_group_id).count

      if chk_available_component_value == 0
        @salary_amount = Hash.new
        salary[1].each do |sal|
          @salary_amount[sal["salary_head_id"]] = sal["salary_amount"]
        end

        EveryMonthCompValue.create :paymonth_id => pay_month_id, :employee_id => salary[1][0]["employee_id"], :salary_group_id => salary_group_id, :salary_amount => @salary_amount
      else
        salary[1].each do |sal|
          EveryMonthCompValue.connection.execute("UPDATE every_month_comp_values SET salary_amount = salary_amount || ('#{sal["salary_head_id"]}' => '#{sal["salary_amount"]}') where employee_id = '#{salary[1][0]["employee_id"]}' and paymonth_id = '#{pay_month_id}' and salary_group_id = '#{salary_group_id}'")
        end
      end
    end
  end


  def self.salary_calculation_days sal_grp_det_id,no_of_pay_days,no_of_present_days,no_of_day_in_selected_month
    calc_based_on = (SalaryGroupDetail.based_on sal_grp_det_id)[0][:based_on]
    if calc_based_on == "Pay Days"
      days_for_calculation = no_of_pay_days
    elsif calc_based_on == "Present Days"
      days_for_calculation = no_of_present_days
    else
      days_for_calculation = no_of_day_in_selected_month
    end
    days_for_calculation
  end

  def self.salary_on_salary_sheet salary_type, month_year, employee_id
    month_year = Date.strptime month_year, '%b/%Y'
    Salary.connection.execute("select * FROM salary_heads LEFT JOIN salaries ON salary_heads.id = salary_head_id and employee_id = '#{employee_id}' and extract(month from effective_date) = #{month_year.month} and extract(year from effective_date) = #{month_year.year} WHERE salary_type = '#{salary_type}'")
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

      salary_earning = salary_on_salary_sheet "Earnings", month_year,emp_salary_data.id.to_s
      salary_deduction = salary_on_salary_sheet "Deductions", month_year,emp_salary_data.id.to_s
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