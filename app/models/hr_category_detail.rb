class HrCategoryDetail < ActiveRecord::Base
  acts_as_audited

  belongs_to :hr_category
  delegate :category_name, :to => :hr_category, :prefix => true
end
