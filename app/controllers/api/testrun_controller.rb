require 'jenkins_api_client'

class Api::TestrunController < ApplicationController
	def index
		render text: params.to_json
	end
	def run
		#sleep 3
		tests = params[:tests].join(",")
		tests = "all" if tests.eql?('@all')




		@client = JenkinsApi::Client.new(:server_ip => '192.168.162.78',
																		 :username => params[:username],
																		 :password => params[:password])


		job_name = "EventiciousTestURI"

		job_params = { :BuildConfiguration => "Release",
									 :ServerConfig => params[:server],
									 :Preview => false,
									 :OS_Platform => params[:platform],
									 :ConferenceName => "TEST_CONF",
									 :ApplicationId => params[:appId],
									 :Branch => params[:branch],
									 :Locale => "ru",
									 :API_version => "v2",
									 :device=>params[:device],
									 :suite => params[:suite],
									 :tests => tests}



		jenkins_job = JenkinsApi::Client::Job.new(@client)
		return_code = jenkins_job.build(job_name, job_params)
		current_build = jenkins_job.get_current_build_number(job_name)

		render json: {
				          :job_params => job_params,
									:build=>current_build+1
		},
					 status: return_code
	end
	def activeDevices
		udid = `system_profiler SPUSBDataType | sed -n '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'`
		udid.delete!("\n")
		androidDevices = `adb devices`
		nexus4 = androidDevices.include?("04d228289809504a")
		nexus7 = androidDevices.include?("015d2578a21c1403")
		iPhone = !udid.empty?

		render json: {
				:iPhone => iPhone,
				:android => {
						:nexus4 => nexus4,
						:nexus7 => nexus7

				}
		},
				status: 200
	end
end
