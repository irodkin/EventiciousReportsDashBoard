require 'jenkins_api_client'
require 'uri'
require 'mercurial-ruby'

class Api::TestrunController < ApplicationController
  def index
    render text: params.to_json
  end
  def run
    tests = params[:tests].join(",")

    testBranch = check_branch_exists(params[:branch], params[:job])

    @client = JenkinsApi::Client.new(:server_ip => '192.168.162.78',
                                     :username => URI.decode_www_form_component(params[:username]),
                                     :password => URI.decode_www_form_component(params[:password]))


    job_name = params[:job]

    job_params = {:BuildConfiguration => "Release",
                  :ServerConfig => params[:server],
                  :Preview => false,
                  :OS_Platform => params[:platform],
                  :ConferenceName => "TEST_CONF",
                  :ApplicationId => params[:appId][/\d+/],
                  :Branch => params[:branch],
                  #:API_version => "v3",
                  :app_type => params[:appType],
                  :locale => params[:locale],
                  :suite => params[:suite],
                  :tests => tests}

    job_params[:TestBranch] = testBranch unless testBranch.nil?

    if params[:rerun].eql?('true')
      report = Report.find(params[:report_id])
      job_params[:RERUN_BUILD_USER_EMAIL] = report.user_email unless report.user_email.nil?
      job_params[:RERUN_BUILD_NUMBER] = report.build unless report.build.nil?
    end

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

#  def activeDevices
  #  udid = `system_profiler SPUSBDataType | sed -n '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'`
#  end

  def createJob
    job = Job.new(:title=>params[:title])
    if job.save
      render json: job,
        status: 200
    else
      render status: 500
    end
  end

  private

  def check_branch_exists(branch, job)
    dev_branch = branch.sub(/^.+\//, "").sub(".","_")
    repository = Mercurial::Repository.open("#{Dir.home}/Jenkins/workspace/#{job}/Events.tests")
    #Override of private method in Mercurial-Ruby
    Mercurial::BranchFactory.class_eval do
        def build(data)
          name, last_commit, status = *data.scan(/([\w*\/\w*\- ]+)\s+\d+:(\w+)\s*\(*(\w*)\)*/).first
          Mercurial::Branch.new(
            repository,
            name,
            :commit => last_commit,
            :status => status
          )
        end
    end
    branches = repository.branches.all
    active_branches = []
    branches.each do |b|
      active_branches.push b.name.gsub("Mobile/", "") if b.name.include? "Mobile/" unless b.closed?
    end
    branch_exist = "default"
    branch_exist = dev_branch if active_branches.include? dev_branch
    return branch_exist
  end
end
