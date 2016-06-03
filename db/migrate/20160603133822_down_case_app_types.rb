class DownCaseAppTypes < ActiveRecord::Migration
  def change
    Report.all.each do |report|
      report.update(app_type:report.app_type.downcase)
    end
  end
end
