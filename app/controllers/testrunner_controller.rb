class TestrunnerController < ApplicationController
	def index
		@jobs = Job.all
		@feature = Suite.all
		@head_tag = Suite.first.tag unless Suite.first.nil?
		@tests = Test.where(suite: @feature.first).all
	end
	def get_scenario_of_feature
		scenarios = Test.where(suite: params[:suite]).all
		suite_title = params[:suite]
		suite_tag = Suite.where(title: params[:suite]).first.tag
		edit = params[:edit] == 'true' ? true : false
		render partial: 'shared/scenarios', locals: {scenarios: scenarios, edit: edit, suite_title: suite_title, suite_tag: suite_tag}
	end
	def reply_run_params
		report = Report.find(params[:report_id])
		render json: {
			platform: report.platform,
			branch: report.branch,
			appid: report.appid,
			app_type: report.app_type,
			locale: report.locale,
			suite: report.suite,
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
	def builds
		#RestClient::Exceptions::ReadTimeout
		job_info = JSON.parse(RestClient.get("http://jenkins.mercury.office:8080/job/#{params[:job]}/api/json?pretty=true&tree=builds[actions[parameters[*]],building,number,result,url,builtOn]{0,20},nextBuildNumber,inQueue"))
		builds=[]
		queue_count=0
		if job_info["inQueue"]
			Nokogiri::XML(RestClient.get("http://jenkins.mercury.office:8080/queue/api/xml?tree=items[actions[parameters[*]],blocked,buildable,id,inQueueSince,stuck,task[name],why,pending]&xpath=/queue/item[task/name='#{params[:job]}']&wrapper=queue")).xpath('./queue/item').each {|i|
				params = i.xpath('./action/parameter').collect {|p| "#{p.xpath('./name').text}=#{p.xpath('./value').text}"}
				builds << {"status"=>"IN_QUEUE", "params"=>params}
				queue_count+=1
			}
			queue_count-=1
			builds[queue_count]["number"] = job_info["nextBuildNumber"]
			while queue_count>0
				queue_count-=1
				builds[queue_count]["number"] = builds[queue_count+1]["number"]+1
			end
		end
		job_info["builds"].each {|b|
			params = b["actions"][0]["parameters"].collect {|p| "#{p["name"]}=#{p["value"]}"}
			builds << {"number"=>b["number"], "status"=>b["building"] ? "IN_PROGRESS" : b["result"], "params"=>params}
		}
		render partial: 'shared/buildstable', locals: {builds: builds}
	end
end
