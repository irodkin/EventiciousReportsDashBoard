class AddResultsOfTestsInReports < ActiveRecord::Migration
  def change
    add_column :reports, :all, :integer
    add_column :reports, :failed, :integer
  end
end
