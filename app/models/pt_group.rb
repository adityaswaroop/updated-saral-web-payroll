class PtGroup < ActiveRecord::Base
  acts_as_audited

  belongs_to :state
  validates_presence_of :state_id, :name, :address
  validates_uniqueness_of :name
  has_many :pt_rates
  has_many :branches

  has_many :pt_group_rates


  def to_date(paymonth_id)
    next_row = next_row_on_pf_group_id paymonth_id
    (Date.strptime(Paymonth.find(next_row.paymonth_id).month_name, "%b/%Y")-1).strftime("%d-%m-%Y") if next_row
  end

  def next_row_on_pf_group_id(paymonth_id)
    PtGroupRate.where("pt_group_id = ? AND paymonth_id > ?", self.id, paymonth_id).order("paymonth_id").first
  end

end
