class JenkinsController < ApplicationController
	def initialize
		@status_images = {"ABORTED"=>"#{JENKINS_URL}static/aaf3e3e1/images/16x16/aborted.png",
		                  "SUCCESS"=>"#{JENKINS_URL}static/aaf3e3e1/images/16x16/blue.png",
		                  "FAILURE"=>"#{JENKINS_URL}static/aaf3e3e1/images/16x16/red.png",
		                  "IN_PROGRESS"=>"#{JENKINS_URL}static/aaf3e3e1/images/16x16/blue_anime.gif",
		                  "IN_QUEUE"=>"#{JENKINS_URL}static/aaf3e3e1/images/16x16/hourglass.png",
		                  "UNKNOWN"=>"questionmark.png"}
	end
	def builds
		#RestClient::Exceptions::ReadTimeout
		job_info = JSON.parse(RestClient::Request.execute(method: :get, url: "#{JENKINS_URL}job/#{params[:job]}/api/json?pretty=true&tree=builds[actions[parameters[*]],building,number,result,url,builtOn]{0,20},nextBuildNumber,inQueue", timeout:5))
		builds = []
		queue_count = 0
		if job_info["inQueue"]
			Nokogiri::XML(RestClient.get("#{JENKINS_URL}queue/api/xml?tree=items[actions[parameters[*]],blocked,buildable,id,inQueueSince,stuck,task[name],why,pending]&xpath=/queue/item[task/name='#{params[:job]}']&wrapper=queue")).xpath('./queue/item').each {|i|
				params = i.xpath('./action/parameter').collect {|p| "#{p.xpath('./name').text}=#{p.xpath('./value').text}"}
				builds << {"status"=>"IN_QUEUE", "params"=>params}
				queue_count += 1
			}
			queue_count -= 1
			builds[queue_count]["number"] = job_info["nextBuildNumber"]
			while queue_count > 0
				queue_count -= 1
				builds[queue_count]["number"] = builds[queue_count+1]["number"]+1
			end
		end
		job_info["builds"].each {|b|
			#find because order of hash with parameters key is not constant in array
			params = b["actions"].find {|h| h.has_key?("parameters")}["parameters"].collect {|p| "#{p["name"]}=#{p["value"]}"}
			builds << {"number"=>b["number"], "status"=>b["building"] ? "IN_PROGRESS" : b["result"], "params"=>params}
		}
		render partial: 'shared/buildstable', locals: {builds: builds}
	end
	def current_builds
		current_builds = []
		Job.find_each {|job|
			job_title = job.title
			begin
				job_info = JSON.parse(RestClient::Request.execute(method: :get, url: "#{JENKINS_URL}job/#{job_title}/api/json?pretty=true&tree=lastBuild[actions[parameters[*]],building,number,result,url,builtOn]{0,20},nextBuildNumber,inQueue", timeout:5))
			rescue => e
				puts e
				build = {"number"=>e.message, "status"=>"UNKNOWN", "link"=>"#{JENKINS_URL}job/#{job_title}", "link_text"=>"Job"}
			else
				if job_info["lastBuild"]["result"] && job_info["inQueue"]
					#Nokogiri::XML(RestClient.get("#{JENKINS_URL}queue/api/xml?tree=items[actions[parameters[*]],blocked,buildable,id,inQueueSince,stuck,task[name],why,pending]&xpath=/queue/item[task/name='#{params[:job]}']&wrapper=queue")).xpath('./queue/item').each {|i|
					build = {"number"=>"##{job_info["nextBuildNumber"]}", "status"=>"IN_QUEUE", "link"=>"#{JENKINS_URL}job/#{job_title}", "link_text"=>"Job"}
				else
					build = {"number"=>"##{job_info["lastBuild"]["number"]}", "status"=>job_info["lastBuild"]["building"] ? "IN_PROGRESS" : job_info["lastBuild"]["result"], "link"=>"#{JENKINS_URL}job/#{job_title}/#{job_info["lastBuild"]["number"]}/parameters", "link_text"=>"Build parameters"}
				end
			end
			current_builds << {job_title: job_title, build: build}
		}
		render partial: 'shared/currentbuilds', locals: {current_builds: current_builds}
	end
end
