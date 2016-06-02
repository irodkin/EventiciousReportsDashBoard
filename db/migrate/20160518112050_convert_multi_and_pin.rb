class ConvertMultiAndPin < ActiveRecord::Migration
  def change
    Report.all.each do |report|
      if report.suite.include?("Multi")
        new_hash = {}
        new_hash[:suite] = report.suite.sub("Multi","")
        new_hash[:tests] = report.tests.gsub(/@multi_*/,"@")
        new_hash[:failed_tests] = report.failed_tests.gsub(/multi_*/,"")
        new_hash[:pending_tests] = report.pending_tests.gsub(/multi_*/,"")
        report.update(new_hash)
      elsif report.suite.include?("Pin")
        new_hash = {}
        new_hash[:suite] = report.suite.sub("Pin","")
        new_hash[:tests] = report.tests.gsub(/@pin_*/,"@").sub("open_recent_conf","pin_open_recent_conf")
        new_hash[:failed_tests] = report.failed_tests.gsub(/pin_*/,"").sub("open_recent_conf","pin_open_recent_conf")
        new_hash[:pending_tests] = report.pending_tests.gsub(/pin_*/,"").sub("open_recent_conf","pin_open_recent_conf")
        report.update(new_hash)
      end
    end
  end
end
