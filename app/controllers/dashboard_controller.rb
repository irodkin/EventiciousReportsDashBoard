
class DashboardController < ApplicationController
  before_filter :find_by, only: [:index]
  def index
    r = Report.all
  	@title = "Last Reports"
    @reports = by_date(10)
    @branches = find_by(:branch)
    @platforms = find_by(:platform)
    @suites = find_by(:suite)
    @servers = find_by(:server)
    @users = find_by(:user)
    @total_count = r.size
    @total_results = total_results
    @result_per_run = result_per_run
    render 'dashboard/index'
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

  def find_by(how=:id)
    result = Report.group(how.to_sym).count
    result.each do |r|
      if r[0].nil? || r[0] == "" || r[1] == 0
        result.delete(r[0])
      end
    end
    result
  end

  def total_results
    failed = 0
    all = 0
    pending = 0
    Report.all.each do |r|
      all += r.all.to_i unless r.all.nil?
      failed += r.failed.to_i unless r.failed.nil?
      pending +=r.pending_tests.size unless r.pending_tests.nil?
    end
    {passed: all-failed, failed: failed, pending: pending}
  end

  def result_per_run
    perfect = 0
    good = 0
    bad = 0
    Report.all.each do |r|
      unless r.failed.nil? && r.all.nil?
        if r.failed.to_f/r.all.to_f*100 > 25
          bad+=1
        elsif r.failed.to_f/r.all.to_f*100 <= 25 && r.failed.to_f/r.all.to_f*100 < 100 && r.failed.to_f != 0
          good+=1
        else
          perfect+=1
        end
      end
    end
    {perfect: perfect, good: good, bad: bad}
  end

  def by_date(limit=5)
    reports = Report.order("date DESC")
    reports.first(limit)
  end

end
