class DashboardController < ApplicationController
  def index
    @title = "Last Reports"
    @branches = group_by(:branch)
    @platforms = group_by(:platform)
    @app_types = group_by(:app_type)
    #@api_versions = group_by(:api_version)
    @locales = group_by(:locale)
    @suites = group_by(:suite)
    @servers = group_by(:server)
    @users = group_by(:user)
    @total_count = Report.count
    @total_results = total_results
    @result_per_run = result_per_run
    render 'dashboard/index'
  end
  def get_report_table_body
    @reports = Report.includes(:job).order(date: :desc) #replace by join?
    count = params[:filters].delete(:count).to_i
    params[:filters].each {|key,value|
      @reports = @reports.select {|r| r[key.to_sym].to_s.include?(value)}
    }
    @reports = @reports[0..count-1]
    render partial: 'shared/reporttablebody'
  end
  def destroy
    record = Report.find(params[:id])
    if record.destroy
      render json: { :success=>true },
             status: 200
    else
      render json: { :success=>false },
             status: 500
    end
  end

  private

  def group_by(how=:id)
    Report.group(how).count.reject{|k,v| k==""}
  end

  def total_results
    #don't know what is faster or better - sum or manual sum
    #failed = 0
    failed = Report.sum(:failed)
    #all = 0
    all = Report.sum(:all)
    pending = 0
    Report.find_each do |r|
      #all += r.all.to_i unless r.all.nil?
      #failed += r.failed.to_i unless r.failed.nil?
      pending += r.pending_tests.split("&&").size unless r.pending_tests.nil?
    end
    {passed: all-failed-pending, failed: failed, pending: pending}
  end

  def result_per_run
    perfect = 0
    good = 0
    bad = 0
    Report.find_each do |r|
      unless r.failed.nil? && r.all.nil?
        if r.failed.to_f/r.all.to_f*100 > 25
          bad += 1
        elsif r.failed.to_f/r.all.to_f*100 <= 25 && r.failed.to_f/r.all.to_f*100 < 100 && r.failed.to_f != 0
          good += 1
        else
          perfect += 1
        end
      end
    end
    {perfect: perfect, good: good, bad: bad}
  end

end
