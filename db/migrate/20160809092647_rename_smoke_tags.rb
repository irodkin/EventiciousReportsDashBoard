class RenameSmokeTags < ActiveRecord::Migration
  def change
  	Report.where(suite: "Smoke").each do |report|
      new_hash = {}
      new_hash[:tests] = report.tests.
      	gsub("attendees", "attendees_smoke").
      	gsub("gallery", "gallery_smoke")
      new_hash.delete(:tests) if new_hash[:tests] == report.tests

      new_hash[:failed_tests] = report.failed_tests.
      	gsub("attendees", "attendees_smoke").
      	gsub("gallery", "gallery_smoke")
      new_hash.delete(:failed_tests) if new_hash[:failed_tests] == report.failed_tests

      new_hash[:pending_tests] = report.pending_tests.
      	gsub("attendees", "attendees_smoke").
      	gsub("gallery", "gallery_smoke")
      new_hash.delete(:pending_tests) if new_hash[:pending_tests] == report.pending_tests
      
      report.update(new_hash) if new_hash.any?
    end
  end
end
