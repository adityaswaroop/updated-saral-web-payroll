class Paymonth < ActiveRecord::Base
  attr_accessible :month_year, :number_of_days, :from_date, :to_date,:month_name,:default_month,:month_locked
  acts_as_audited

  has_many :pt_rates, :dependent => :restrict
  has_many :pf_group_rates, :dependent => :restrict
  has_many :pt_group_rates, :dependent => :restrict
  has_many :esi_group_rates, :dependent => :restrict
  has_many :every_month_comp_values, :dependent => :restrict

  regex_for_date = /(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(-|\/|\\)(19|20)\d\d/i

  validates :month_name,   :presence   => true,
            :format     => { :with => regex_for_date },
            :uniqueness => { :case_sensitive => false }


  def self.find_month_details_to_save paymonth
    date_var = Date.strptime paymonth, "%b/%Y"
    number_of_days = Time.days_in_month date_var.month,date_var.year
    month_year_digit = ((date_var.year*12)+date_var.month)
    return [month_year_digit,number_of_days,date_var.beginning_of_month.strftime("%Y-%m-%d"),date_var.end_of_month.strftime("%Y-%m-%d"),paymonth]
  end

  def self.proceed_to_save paymonth
    result = true
    if Paymonth.count > 0
      last_paymonth = Date.strptime Paymonth.last.month_name, "%b/%Y"
      param_paymonth = Date.strptime paymonth, "%b/%Y"
      result = false if last_paymonth.next_month.strftime("%b/%Y") != param_paymonth.strftime("%b/%Y")
      next_paymonth = last_paymonth.next_month.strftime("%b/%Y")
    end
    [result,next_paymonth]
  end

  def self.next_paymonth
      last_paymonth = Date.strptime Paymonth.last.month_name, "%b/%Y"
      last_paymonth.next_month.strftime("%b/%Y")
  end

  def salary_calculated
    var_date = Date.strptime month_name, "%b/%Y"
    emp_list = Employee.employee_list month_name
    salaried_emp_list = Salary.select('employee_id').where("extract(month from effective_date) = #{var_date.month}").group('employee_id')
    emp_list.count == salaried_emp_list.length ? result = "Yes" : result = "No"
    result
  end

  def update_default_month
    saved_default_month = Paymonth.find_by_default_month(true)
    saved_default_month.update_attribute(:default_month,false) if !saved_default_month.blank?
    latest_mon_as_default_month
  end

  def latest_mon_as_default_month
    current_paymonth = Paymonth.last
    if !current_paymonth.blank?
      current_paymonth.update_attribute(:default_month,true)
      update_global_default_month
    end
  end

  def update_paymonths paymonths
    paymonths.each do |paymonth_det|
      pay_month = Paymonth.find(paymonth_det[1]['paymonth_id'])
      pay_month.update_attributes(:default_month=>paymonth_det[1]['default_month'],:month_locked=>paymonth_det[1]['Lock_Month'])
    end
    update_global_default_month
  end

  def update_global_default_month
    glb = Global.instance
    glb.setter_paymonth_default_month
  end

  scope :months, :order => 'created_at DESC'
  scope :not_locked_months, lambda { where('month_locked = false').order('created_at DESC') }

end
