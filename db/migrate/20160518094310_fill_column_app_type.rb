class FillColumnAppType < ActiveRecord::Migration
  def change
    Report.all.each do |report|
      if report.app_type == nil
        if report.suite.include?("Multi")
          app_type = "Multi"
        elsif report.suite.include?("Pin")
          app_type = "Pin"
        else
          app_type = "Single"
        end
        report.update(app_type:app_type)
      end
    end
  end
end
