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

  def paymonth_name

  end

  scope :months, :order => 'created_at DESC'

end
