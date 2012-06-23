class EmployeeDetail < ActiveRecord::Base

  attr_accessible :employee_id, :effective_date, :salary_group_id, :allotted_gross,:classification,:branch_id,:financial_institution_id,:attendance_configuration_id,:bank_account_number,:effective_to,:international_worker
  acts_as_audited

  attr_accessor :current_employee_id

  serialize :classification, ActiveRecord::Coders::Hstore

  belongs_to :employee
  belongs_to :salary_group
  belongs_to :financial_institution
  belongs_to :branch
  belongs_to :attendance_configuration

  has_many :salary_allotments, :dependent => :destroy
  has_many :salaries, :dependent => :destroy
  has_many :classification_headings

  validates_presence_of :employee_id
  validates_presence_of :salary_group_id
  validates_presence_of :effective_date
  validates_uniqueness_of :employee_id, :scope => [:effective_date],:message => "Details already exist for the same date"
  validate :effective_date_after_doj
  validate :effective_date_before_dol
  validate :date_validation_on_update, :on => :update
  validate :date_validation_on_save, :on => :create


  delegate :salary_group_name, :to => :salary_group, :prefix => true
  delegate :empname, :to => :employee, :prefix => true


  def effective_date_after_doj
     if effective_date < Employee.find(employee_id).date_of_joining then
      errors.add(:effective_date, "should be after date of joining")
    end
  end

  def effective_date_before_dol
    if Employee.find(employee_id).date_of_leaving != nil then
      if effective_date > Employee.find(employee_id).date_of_leaving then
        errors.add(:effective_date, "should be before date of leaving")
      end
    end
  end

  def date_validation_on_save
    last_record = EmployeeDetail.where(:employee_id=>employee_id).order('created_at desc').first
    if !last_record.nil?
      errors.add(:effective_date, "should be after date of last saved Effective date") if effective_date < last_record.effective_date
    end
  end

  def date_validation_on_update
    last_record = EmployeeDetail.where(:employee_id=>employee_id).order('created_at desc').second
    if !last_record.nil?
      errors.add(:effective_date, "should be after date of last saved Effective date") if effective_date < last_record.effective_date
    end
  end

  def do_update_after_save
    if EmployeeDetail.count(:conditions => "employee_id = #{employee_id}") >= 2
       record_id_to_update = EmployeeDetail.where(:employee_id=>employee_id).order('created_at desc').second
       if !record_id_to_update.nil?
         record_id_to_update.update_attribute(:effective_to,effective_date-1)
       end
    end
  end

  def do_update_after_delete
    if EmployeeDetail.count(:conditions => "employee_id = #{employee_id}") >= 1
      record_id_to_update = EmployeeDetail.where(:employee_id=>employee_id).order('created_at desc').first
      record_id_to_update.update_attribute(:effective_to,nil)
    end
  end

  def employee_salary_allotment
    sal_gr_id = salary_group_id
    SalaryGroupDetail.salary_group_details(sal_gr_id).each do |sgd|
      SalaryAllotment.create!(:employee_id => employee_id, :employee_detail_id => id, :effective_date => effective_date, :salary_head_id => sgd.salary_head_id, :salary_group_detail_id => sgd.id, :salary_allotment =>0)
    end
  end

  def self.employee_branch month_date, emp_id
    emp_det_branch = EmployeeDetail.select('branch_id').where("effective_date = '#{month_date.beginning_of_month}' and employee_id = ?",emp_id)
    if emp_det_branch.count > 0
      emp_branch = emp_det_branch
    else
      emp_branch =  EmployeeDetail.select('branch_id').where("effective_date = (select MAX(effective_date) from employee_details where employee_id = #{emp_id}) and employee_id = ?",emp_id)
    end
    emp_branch
  end
end
