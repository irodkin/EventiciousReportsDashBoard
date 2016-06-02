class TestrunnerController < ApplicationController
	def index
		@jobs = Job.all
		@feature = Suite.all
		@head_tag = Suite.first.tag unless Suite.first.nil?
		@tests = Test.where(suite: @feature.first).all
	end
	def get_scenario_of_feature
		scenarios = Test.where(suite: params[:suite]).all
		if params[:edit] == 'true'
			edit = true
			suite_title = params[:suite]
			suite_tag = Suite.where(title: params[:suite]).first.tag
		else
			edit = false
		end
		render partial: 'shared/scenarios', locals: {scenarios: scenarios, edit: edit, suite_title: suite_title, suite_tag: suite_tag}
	end
	def add_feature
		suites = Suite.all
		render partial: 'shared/addfeature', locals: {suites: suites}
	end
	def reply_run_params
		report = Report.find(params[:report_id])
		render json: {
			platform: report.platform,
			branch: report.branch,
			appid: report.appid,
			app_type: report.app_type,
			suite: report.suite,
			device: report.device,
			server: report.server,
			job: report.job
		},
		status: 200
	end
	def reply_all
		report = Report.find(params[:report_id])
		if report.tests.kind_of?(Array)
			tests = report.tests.each { |t| t.delete("@")}
		else
			tests = report.tests.delete("@")
		end
		render json: {tests: tests},
		status: 200
	end
	def reply_failed
		report = Report.find(params[:report_id])
		render json: {
			failed_tests: report.failed_tests,
			pending_tests: report.pending_tests
		},
		status: 200
	end
	def tests
		tests = Test.where(suite: params[:suite]).all
		tags_arr = tests.collect { |t| t.tags}
		split = []
		to_delete = []
		tags_arr.collect! do |t|
			if t.split(",").size>1
				t.split(",").each {|t| split.push t }
				to_delete.push t
			end
			t
		end
		to_delete.each {|d| tags_arr.delete d}
		split.each {|s| tags_arr.push s}
		scenarios = []
		tags_arr.uniq!
		tags_arr.each do |t|
			scenarios_a = tests.find_all { |f| f.tags.split(",").include?(t)}
			scenarios_b = []
			scenarios_a.each do |s|
				scenarios_b.push "<div><span class=\"keyword\">Scenario: </span><span class=\"scenario_title\">#{s.title}<span></div><div style=\"margin-left: 5px\">#{s.steps}</div>"
			end
			scenarios.push([scenarios_b, t])
		end
		head_tag = Suite.where(title: params[:suite]).first.tag
		render partial: 'shared/tests', locals: {tests: scenarios, head_tag: head_tag}
	end
end
