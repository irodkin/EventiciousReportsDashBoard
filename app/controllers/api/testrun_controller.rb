require 'jenkins_api_client'

class Api::TestrunController < ApplicationController
  def index
    render text: params.to_json
  end
  def run
    tests = params[:tests].join(",")

    if params[:suite].eql?("MultiBigSmoke")
      multi = true
    else
      multi = false
    end

    @client = JenkinsApi::Client.new(:server_ip => '192.168.162.78',
                                     :username => params[:username],
                                     :password => params[:password])


    job_name = params[:job]

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
                   :tests => tests,
                   :multi => multi}



    jenkins_job = JenkinsApi::Client::Job.new(@client)
    return_code = jenkins_job.build(job_name, job_params)
    current_build = jenkins_job.get_current_build_number(job_name)

    render json: {
      :job_params => job_params,
      :job_name => job_name,
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
  def createJob
    job = Job.new(:title=>params[:title])
    if job.save
      render json: job,
        status: 200
    else
      render status: 500
    end
  end
end
