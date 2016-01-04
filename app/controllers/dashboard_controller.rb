
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
    @total_count = r.size
    @total_results = total_results
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
    Report.group(how.to_sym).count
  end

  def total_results
    failed = 0
    all = 0
    pending = 0
    Report.all.each do |r|
      all += r.all.to_i
      failed += r.failed.to_i
      pending +=r.pending_tests.size unless r.pending_tests.nil?
    end
    return {"passed"=>all-failed, "failed"=>failed, "pending"=>pending}
  end

  def by_date(limit=5)
    reports = Report.order("date DESC")
    reports.first(limit)
  end

end
