class TestrunnerController < ApplicationController
	def index
		@jobs = Job.all
		@feature = Suite.all
	end
	def get_scenario_of_feature
		scenarios = Test.where(suite: params[:suite]).all
		suite_title = params[:suite]
		suite_tag = Suite.find_by(title: params[:suite]).tag
		edit = params[:edit] == 'true' ? true : false
		render partial: 'shared/scenarios',
		       locals: {scenarios: scenarios,
		                edit: edit,
		                suite_title: suite_title,
		                suite_tag: suite_tag}
	end
	def retry_run_params
		report = Report.find(params[:report_id])
		render json: {platform: report.platform,
		              branch: report.branch,
		              appid: report.appid,
		              app_type: report.app_type,
		              api_version: report.api_version,
		              locale: report.locale,
		              suite: report.suite,
		              server: report.server,
		              job: report.job.title},
		       status: 200
	end
	def retry_all
		report = Report.find(params[:report_id])
		tests = report.tests.delete("@")
		render json: {tests: tests},
		status: 200
	end
	def retry_failed
		report = Report.find(params[:report_id])
		render json: {failed_tests: report.failed_tests,
		              pending_tests: report.pending_tests},
		       status: 200
	end
	def tests
		scenarios = Test.where(suite: params[:suite]).all
		tags = scenarios.inject([]) {|all_tags, test| all_tags + test.tags.split(",")}.uniq
		scenarios_with_tags = tags.collect {|tag|
			scenarios_with_tag = scenarios.find_all {|f| f.tags.split(",").include?(tag)}
			{tag: tag, scenarios: scenarios_with_tag}
		}
		head_tag = Suite.find_by(title: params[:suite]).tag
		render partial: 'shared/tests',
		       locals: {scenarios_with_tags: scenarios_with_tags, head_tag: head_tag}
	end
end
