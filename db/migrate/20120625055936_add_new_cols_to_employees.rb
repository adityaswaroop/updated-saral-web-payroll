class AddNewColsToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :restrict_esi, :boolean, :default => "false"
  end
end
