class CreateEveryMonthCompValue < ActiveRecord::Migration
  def change
    create_table :every_month_comp_values do |t|
      t.references :paymonth
      t.references :employee
      t.references :salary_group
      t.references :salary_head
      t.decimal :salary_amount, :precision => 8, :scale => 2

      t.timestamps
    end
    add_index :every_month_comp_values, :employee_id
    #add_index :every_month_comp_values, :paymonth_id
    add_index :every_month_comp_values, :salary_group_id
    add_foreign_key :every_month_comp_values, :employees
    add_foreign_key :every_month_comp_values, :paymonths
    add_foreign_key :every_month_comp_values, :salary_groups

    remove_column :every_month_comp_values, :salary_head_id
    remove_column :every_month_comp_values, :salary_amount
    add_column :every_month_comp_values, :salary_amount, :hstore

  end
end
