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
																		 :username => 'DashBoardRunner',
																		 :password => '1234567890')


		job_params = { :BuildConfiguration => "Release",
									 :ServerConfig => params[:server],
									 :Preview => false,
									 :OS_Platform => params[:platform],
									 :ConferenceName => "TEST_CONF",
									 :ApplicationId => params[:appId],
									 :Branch => params[:branch],
									 :Locale => "ru",
									 :API_version => "v2",
									 :suite => params[:suite],
									 :tests => tests}

		jenkins_job = JenkinsApi::Client::Job.new(@client)
		return_code = jenkins_job.build("EventiciousTestURI", job_params)




		render json: job_params,
					 status: return_code
	end
end
