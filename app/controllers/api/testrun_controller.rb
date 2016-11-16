require 'jenkins_api_client'
require 'uri'
#require 'mercurial-ruby'
require 'git'

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

    job_params = {#:BuildConfiguration => "Release",
                  :ServerConfig => params[:server],
                  #:Preview => false,
                  :OS_Platform => params[:platform],
                  #:ConferenceName => "TEST_CONF",
                  :ApplicationId => params[:appId][/\d+/],
                  :Branch => params[:branch],
                  #:API_version => params[:apiVersion],
                  :app_type => params[:appType],
                  :locale => params[:locale],
                  :suite => params[:suite],
                  :tests => tests,
                  :iterations => params[:iterations]}

    if params[:rebuildApp] == "false"
      node_label = where_run_without_rebuilding?(params)
      if node_label
        job_params[:rebuild_app] = false
        job_params[:node_label] = node_label
      end
    end

    job_params[:TestBranch] = testBranch unless testBranch.nil?

    if params[:rerun].eql?('true')
      report = Report.find(params[:report_id])
      job_params[:RERUN_BUILD_USER_EMAIL] = report.user_email unless report.user_email.nil?
      job_params[:RERUN_BUILD_NUMBER] = report.build unless report.build.nil?
    end

    jenkins_job = @client.job
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
    dev_branch = branch.sub(/^.+?\//,"").sub(/\/.+$/,"").sub(".","_") #get rid of various pre- and postfixes
    #repository = Mercurial::Repository.open("#{Dir.home}/Jenkins/workspace/#{job}/Events.tests")
    repository = Git.open("#{Dir.home}/Jenkins/workspace/#{job}/Events.tests")
    ##Override of private method in Mercurial-Ruby
    #Mercurial::BranchFactory.class_eval do
    #    def build(data)
    #      name, last_commit, status = *data.scan(/([\w*\/\w*\- ]+)\s+\d+:(\w+)\s*\(*(\w*)\)*/).first
    #      Mercurial::Branch.new(
    #        repository,
    #        name,
    #        :commit => last_commit,
    #        :status => status
    #      )
    #    end
    #end
    #branches = repository.branches.all
    #active_branches = []
    #branches.each do |b|
    #  active_branches.push b.name.gsub("Mobile/", "") if b.name.include? "Mobile/" unless b.closed?
    #end
    mobile_branch_names = []
    repository.branches.remote.each {|b| mobile_branch_names << b.name.sub("Mobile/", "") if b.name.start_with?("Mobile")}
    branch_exist = "default"
    #branch_exist = dev_branch if active_branches.include? dev_branch
    branch_exist = dev_branch if mobile_branch_names.include? dev_branch
    return branch_exist
  end
  def where_run_without_rebuilding?(params)
    #nodes_label = Nokogiri::XML(RestClient.get("http://jenkins.mercury.office:8080/job/Eventicious_UITests_MultipileSCM/api/xml?tree=actions[parameterDefinitions[name,defaultParameterValue[value]]]&xpath=/freeStyleProject/action/parameterDefinition[name='Node_label']/defaultParameterValue/value")).text() #not working because of bug in plugin; need update to version 1.6 minimum
    nodes_label = Nokogiri::XML(RestClient.get("http://jenkins.mercury.office:8080/job/#{params[:job]}/api/xml?tree=actions[parameterDefinitions[name,description]]&xpath=/freeStyleProject/action/parameterDefinition[name='node_label']/description")).text()
    nodes_names = Nokogiri::XML(RestClient.get("http://jenkins.mercury.office:8080/label/#{nodes_label}/api/xml?tree=nodes[nodeName]&xpath=/labelAtom/node/nodeName&wrapper=nodes")).xpath("./nodes/nodeName").collect {|n| n.text}
    last_builds_for_platform = {}
    nodes_names.each {|n|
      begin
        last_builds_for_platform[n] = Nokogiri::XML(RestClient.get("http://jenkins.mercury.office:8080/job/#{params[:job]}/api/xml?tree=builds[actions[parameters[*]],result,builtOn]&xpath=/freeStyleProject/build[builtOn='#{n}'][action/parameter[name='OS_Platform'][value='#{params[:platform]}']][1]"))
      rescue RestClient::NotFound
        #do nothing
      end
    }
    where_run_without_rebuilding = nil
    #getting queue
    builds_in_queue_for_platform_with_rebuild = nil
    if JSON.parse(RestClient.get("http://jenkins.mercury.office:8080/job/#{params[:job]}/api/json?tree=inQueue"))["inQueue"]
      begin
        builds_in_queue_for_platform_with_rebuild = Nokogiri::XML(RestClient.get("http://jenkins.mercury.office:8080/queue/api/xml?tree=items[actions[parameters[*]],task[name]]&xpath=/queue/item[task/name='#{params[:job]}'][action/parameter[name='OS_Platform'][value='#{params[:platform]}']][action/parameter[name='rebuild_app'][value='true']][1]"))
      rescue RestClient::NotFound
        #do nothing
      end
    end
    #getting builds
    unless builds_in_queue_for_platform_with_rebuild
      last_builds_for_platform.each {|key,value|
        if build_params_equal?(params, value)
          if value.xpath('.//result').text() == 'SUCCESS'
            where_run_without_rebuilding = key
          else
            if value.xpath(".//parameter[name='rebuild_app']/value").text() == 'false'
              where_run_without_rebuilding = key
            end
          end
        end

        break if where_run_without_rebuilding
      }
    end

    where_run_without_rebuilding
  end
  def build_params_equal?(params, xml_params)
    autotest_apps = ['0','4193','4330','4331','4332','4389','4452','4454','4455']
    if params[:server] == xml_params.xpath(".//parameter[name='ServerConfig']/value").text() &&
       params[:platform] == xml_params.xpath(".//parameter[name='OS_Platform']/value").text() &&
       (autotest_apps.include?(params[:appId][/\d+/]) &&
        autotest_apps.include?(xml_params.xpath(".//parameter[name='ApplicationId']/value").text()) ||
        params[:appId][/\d+/] == xml_params.xpath(".//parameter[name='ApplicationId']/value").text()) &&
       params[:branch] == xml_params.xpath(".//parameter[name='Branch']/value").text() &&
       params[:appType] == xml_params.xpath(".//parameter[name='app_type']/value").text() &&
       params[:locale] == xml_params.xpath(".//parameter[name='locale']/value").text() &&
       params[:apiVersion] == xml_params.xpath(".//parameter[name='API_version']/value").text()
      true
    else
      false
    end
  end
end
