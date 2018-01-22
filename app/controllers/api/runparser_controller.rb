class Api::RunparserController < ApplicationController
	skip_before_filter :verify_authenticity_token
	def parse
		failed_scenarios = params[:failed_scenarios]
		pending_scenarios = params[:pending_scenarios]
		failed_tests = []
		pending_tests = []
		unless failed_scenarios.nil?
			failed_scenarios.uniq.each do |s|
				scenario = Test.where(title: s, suite: params[:suite]).first
				failed_tests.push scenario.tags unless scenario.nil?
			end
		end

		unless pending_scenarios.nil?
			pending_scenarios.uniq.each do |s|
				scenario = Test.where(title: s, suite: params[:suite]).first
				pending_tests.push scenario.tags unless scenario.nil?
			end
		end

		job = Job.find_or_create_by(title: params[:job])
		job_id = job.id

		r = Report.new(date: Time.now + 14400,
		               platform: params[:platform],
		               server: params[:server],
		               suite: params[:suite],
		               tests: params[:tests],
		               link: params[:link],
		               build: params[:build],
		               job_id: job_id,
		               branch: params[:branch],
		               user: params[:user],
		               user_email: params[:user_email],
		               appid: params[:appid],
		               app_type: params[:app_type],
		               locale: params[:locale],
		               api_version: params[:api_version],
		               all: params[:all],
		               failed: params[:failed],
		               failed_tests: failed_tests.join("&&"),
		               pending_tests: pending_tests.join("&&"))
		if r.save
			render status: 200,
			       json: {status: "ok"}
		else
			render status: 500,
			       json: {status: "not ok"}
		end
	end
end
