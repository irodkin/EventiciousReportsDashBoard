class RenameTestTags < ActiveRecord::Migration
  def change
  	Report.all.each do |report|
      new_hash = {}
      new_hash[:tests] = report.tests.
      	gsub("update_schedule", "update_speech").
      	gsub("schedule_document", "speech_with_document").
      	gsub("schedule_ask", "ask_question").
      	gsub("ask_like", "like_question")
      new_hash.delete(:tests) if new_hash[:tests] == report.tests

      new_hash[:failed_tests] = report.failed_tests.
      	gsub("update_schedule", "update_speech").
      	gsub("schedule_document", "speech_with_document").
      	gsub("schedule_ask", "ask_question").
      	gsub("ask_like", "like_question")
      new_hash.delete(:failed_tests) if new_hash[:failed_tests] == report.failed_tests

      new_hash[:pending_tests] = report.pending_tests.
      	gsub("update_schedule", "update_speech").
      	gsub("schedule_document", "speech_with_document").
      	gsub("schedule_ask", "ask_question").
      	gsub("ask_like", "like_question")
      new_hash.delete(:pending_tests) if new_hash[:pending_tests] == report.pending_tests
      
      report.update(new_hash) if new_hash.any?
    end
  end
end
