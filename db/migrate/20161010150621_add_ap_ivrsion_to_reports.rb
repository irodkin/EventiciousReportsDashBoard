class AddApIvrsionToReports < ActiveRecord::Migration
  def change
  	add_column :reports, :api_version, :string
    Report.all.each do |report|
      report.update(api_version:"v4")
    end
  end
end
