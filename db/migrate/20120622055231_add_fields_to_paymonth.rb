class AddFieldsToPaymonth < ActiveRecord::Migration
  def change
    add_column :paymonths, :default_month,:boolean,:default=>false
    add_column :paymonths, :month_locked,:boolean,:default=>false
    add_index :paymonths, :default_month
    add_index :paymonths, :month_locked
  end
end
