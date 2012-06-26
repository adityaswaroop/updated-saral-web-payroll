class AddNewColsToSalaryAllotments < ActiveRecord::Migration
  def change
    add_column :salary_allotments, :earning_total, :decimal, :precision => 8, :scale => 2
    add_column :salary_allotments, :deduction_total, :decimal, :precision => 8, :scale => 2
  end
end
