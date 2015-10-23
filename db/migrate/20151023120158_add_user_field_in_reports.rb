class AddUserFieldInReports < ActiveRecord::Migration
  def change
    add_column :reports, :user, :string
  end
end
