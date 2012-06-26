class Employee < ActiveRecord::Base
  attr_accessible :empname, :date_of_joining, :date_of_leaving, :date_of_birth, :marital_status, :father_name, :spouse_name , :gender, :present_res_no, :present_res_name, :present_street, :present_locality, :present_city, :present_state_id, :perm_res_no, :perm_res_name, :perm_street, :perm_locality, :perm_city, :perm_state_id, :perm_sameas_present , :email, :mobile, :refno, :restrct_pf,:probation_period,:probation_complete_date,:confirmation_date,:salary_start_date,:retirement_date,:handicapped,:emergency_contact_number,:official_mail_id,:leaving_reason,:resignation_date,:notice_period,:remarks
  acts_as_audited

  regex_for_email = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  regex_for_number = /[0-9]/

  has_many :employee_details, :dependent => :destroy

  has_many :leave_details, :dependent => :destroy

  has_many :leave_takens, :dependent => :destroy

  has_many :salary_allotments, :dependent => :destroy
  has_one :employee_statutory, :dependent => :destroy
  has_many :pf_calculated_values, :dependent => :destroy
  has_many :esi_calculated_values, :dependent => :destroy
  has_many :hr_masters, :dependent => :destroy

  has_many :leave_takens, :dependent => :destroy
  has_many :every_month_comp_values, :dependent => :destroy

  belongs_to :present_state, :class_name => "State", :foreign_key => 'present_state_id', :validate => true
  delegate :state_name, :to => :present_state, :prefix => true

  #belongs_to :perm_state, :class_name => "State"
  #delegate :state_name, :to => :perm_state, :prefix => true

  validates :empname, :presence => true,:length   => {:maximum => 100}
  validates :present_state_id, :presence => true
  validates :date_of_joining, :presence => true
  validates :refno,   :presence   => true,:uniqueness => { :case_sensitive => false }
  validates :email, :format => { :with => regex_for_email }, :if => :email_present?
  validates :leaving_reason, :presence => true, :if => :date_of_leaving_present?
  validate :doj_before_dol,:dob_before_doj, :probation_comp_date_after_doj,:confirmation_date_after_doj,:salary_start_date_after_doj,:retirement_date_after_doj

  validates_numericality_of :notice_period, :if => :notice_period_present?

  validates_numericality_of :probation_period, :if => :probation_period_present?

  def probation_period_present?
     !probation_period.nil? and !probation_period.blank?
  end

  def notice_period_present?
     !notice_period.nil? and !notice_period.blank?
  end

  def date_of_leaving_present?
    !date_of_leaving.nil? and !date_of_leaving.blank?
  end

  def email_present?
    !email.nil? and !email.blank?
  end

  def dob_before_doj
    if !date_of_birth.nil? and !date_of_joining.nil? and date_of_birth >= date_of_joining then
      errors.add(:date_of_joining, "date of birth should be before date of joining")
    end
  end

  def doj_before_dol
    if !date_of_joining.nil? and !date_of_leaving.nil? and date_of_joining >= date_of_leaving then
      errors.add(:date_of_joining, "date of joining should be before date of leaving")
    end
  end

  def confirmation_date_after_doj
    if !date_of_joining.nil? and !confirmation_date.nil? and date_of_joining >= confirmation_date then
      errors.add(:confirmation_date, "confirmation date should be after date of joining")
    end
  end

  def probation_comp_date_after_doj
    if !date_of_joining.nil? and !probation_complete_date.nil? and date_of_joining >= probation_complete_date then
      errors.add(:probation_complete_date, "probation complete date should be after date of joining")
    end
  end

  def salary_start_date_after_doj
    if !date_of_joining.nil? and !salary_start_date.nil? and date_of_joining > salary_start_date then
      errors.add(:salary_start_date, " should be after date of joining")
    end
  end

  def retirement_date_after_doj
    if !date_of_joining.nil? and !retirement_date.nil? and date_of_joining >= retirement_date then
      errors.add(:retirement_date, "retirement date should be after date of joining")
    end
  end

  def self.search(search)
    search_condition = "%" + search + "%"
    find(:all, :conditions => ['refno ILIKE ? OR empname ILIKE ? OR email ILIKE ?', search_condition, search_condition, search_condition])
  end

  def self.employee_with_salary_not_allotted
    Employee.joins(:salary_allotments).where("0 = (SELECT SUM(salary_allotment) from salary_allotments WHERE employee_id = employees.id)").group('employees.id')
  end

  def self.employee_with_salary_allotted
    Employee.joins(:salary_allotments).where("0 < (SELECT SUM(salary_allotment) from salary_allotments WHERE employee_id = employees.id)").group('employees.id')
  end

  def self.chk_dol emp_id
    date_of_leaving = Employee.find(emp_id).date_of_leaving
  end

  scope :employees_list, lambda {|month_year|
    where("date_of_leaving IS NULL OR (EXTRACT(MONTH FROM date_of_leaving)=#{month_year.month} AND EXTRACT(YEAR FROM date_of_leaving)=#{month_year.year})").order("created_at ASC")
  }

  def self.report_data report_type,classification
    condition=''
    if classification != nil
      classification = classification.to_hash
      classification.each_pair { |key,value| (condition.length > 1)? condition = condition + " and  classification -> '#{key}' ILIKE '#{value}' " :condition = condition + " classification -> '#{key}' ILIKE '#{value}' " if value != '' }
    end
    (condition.length > 1)? condition = condition + " and #{report_type} IS NOT NULL" : condition = "#{report_type} IS NOT NULL" if report_type != "Contact"
    @employees = Employee.includes(:employee_details).joins(:employee_details).where("#{condition}").order('employees.created_at ASC')

    @employees
  end

  def self.process_employee_excel_sheet employee_excel_sheet
    employees = Hash.new
    employees["employees_save"] = []
    employees["employees_update"] = []
    employees["errors"] = Hash.new
    errors = Hash.new
    counter = 0

    excel_first_row = employee_excel_sheet.first

    if duplicates_in_employee_columns? excel_first_row
      errors["#{counter+1}"] = ["Duplication of Employee Columns"]
    else
      employee_excel_sheet.each 1 do |row|
        counter+=1

        e = Employee.new
        e.refno = row[0].to_s
        e.empname = row[1]
        e.father_name = row[2]
        e.marital_status = row[3]
        e.spouse_name = row[4]
        e.gender = row[5]
        e.date_of_birth = row[6]
        e.date_of_joining = row[7]
        e.date_of_leaving = row[8]
        e.present_res_no = row[9]
        e.present_res_name = row[10]
        e.present_street = row[11]
        e.present_locality = row[12]
        e.present_city = row[13]
        e.present_state = State.find_by_state_name(row[14])
        e.perm_sameas_present = row[15] == "Yes" ? true : false

        if(e.perm_sameas_present)
          e.perm_res_no = e.present_res_no
          e.perm_res_name = e.present_res_name
          e.perm_street = e.present_street
          e.perm_locality = e.present_locality
          e.perm_city = e.present_city
          e.perm_state_id = e.present_state.id
        else
          e.perm_res_no = row[16]
          e.perm_res_name = row[17]
          e.perm_street = row[18]
          e.perm_locality = row[19]
          e.perm_city = row[20]
          e.perm_state_id = State.find_by_state_name(row[21])
        end
        e.email = row[22]
        e.mobile = row[23].to_s
        e.restrct_pf = row[24]
        e.probation_period = row[25]
        e.probation_complete_date = row[26]
        e.confirmation_date = row[27]
        e.salary_start_date = row[28]
        e.retirement_date = row[29]
        e.handicapped = row[30]
        e.emergency_contact_number = row[31]
        e.official_mail_id = row[32]
        e.leaving_reason = row[33]

        if(Employee.exists?(:refno => e.refno))
          employees["employees_update"] << e
        else
          if e.valid?
            employees["employees_save"] << e
          else
            errors["#{counter+1}"] = e.errors
          end
        end
      end
    end
    employees["errors"] = errors
    employees
  end

  def self.duplicates_in_employee_columns? employee_columns
    employee_columns.size != employee_columns.uniq.size ? true : false
  end

  scope :employees, :order => 'created_at DESC'

  def empname_and_refno
    empname+'('+refno.to_s+')'
  end

  def self.employee_list pay_month
    pay_month = Date.strptime pay_month, "%b/%Y"
    employees = Employee.select('id,empname,refno,date_of_leaving').where(" '#{pay_month.beginning_of_month}' >= date_of_joining or #{pay_month.month} = extract(month from date_of_joining) ")
    employee_list = []
    i=0
    employees.each do |employee|
      if employee.date_of_leaving.nil?
        employee_list[i] = {:employee_id=>employee.id,:refno=>employee.refno,:empname=>employee.empname}
        i=i+1
      elsif employee.date_of_leaving.month == pay_month.month or employee.date_of_leaving >= pay_month.end_of_month
        employee_list[i] = {:employee_id=>employee.id,:refno=>employee.refno,:empname=>employee.empname}
        i=i+1
      end
    end
    employee_list
  end

end