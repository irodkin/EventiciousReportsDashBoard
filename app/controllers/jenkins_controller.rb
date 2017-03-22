class JenkinsController < ApplicationController
	def builds
		#RestClient::Exceptions::ReadTimeout
		job_info = JSON.parse(RestClient::Request.execute(method: :get, url: "http://jenkins.mercury.office:8080/job/#{params[:job]}/api/json?pretty=true&tree=builds[actions[parameters[*]],building,number,result,url,builtOn]{0,20},nextBuildNumber,inQueue", timeout:5))
		builds = []
		queue_count = 0
		if job_info["inQueue"]
			Nokogiri::XML(RestClient.get("http://jenkins.mercury.office:8080/queue/api/xml?tree=items[actions[parameters[*]],blocked,buildable,id,inQueueSince,stuck,task[name],why,pending]&xpath=/queue/item[task/name='#{params[:job]}']&wrapper=queue")).xpath('./queue/item').each {|i|
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
end
