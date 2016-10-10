class Api::RunparserController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def parse
    failed_scenarios = params[:failed_scenarios]
    pending_scenarios = params[:pending_scenarios]
    failed_tests = []
    pending_tests = []
    unless failed_scenarios.nil?
      failed_scenarios.uniq.each do |s|
        scenario = Test.where({title: s, suite: params[:suite]}).first
        failed_tests.push scenario.tags unless scenario.nil?
      end
    end

    unless pending_scenarios.nil?
      pending_scenarios.uniq.each do |s|
        scenario = Test.where({title: s, suite: params[:suite]}).first
        pending_tests.push scenario.tags unless scenario.nil?
      end
    end

    r = Report.new(:date=>Time.now+14400,
                   :platform=>params[:platform],
                   :server=>params[:server],
                   :suite=>params[:suite],
                   :tests=>params[:tests],
                   :link=>params[:link],
                   :buildurl=>params[:buildurl],
                   :build=>params[:build],
                   :job=>params[:job],
                   :branch=>params[:branch],
                   :user=>params[:user],
                   :user_email=>params[:user_email],
                   :appid=>params[:appid],
                   :app_type=>params[:app_type],
                   :locale=>params[:locale],
                   :api_version=>params[:api_version],
                   :all => params[:all],
                   :failed => params[:failed],
                   :failed_tests => failed_tests.join("&&"),
                   :pending_tests => pending_tests.join("&&"))
    if r.save
      render json: {
        status: "ok"
      },
      status: 200
    else
      render json: {
        status: "not ok"
      },
      status: 500
    end
  end
end
