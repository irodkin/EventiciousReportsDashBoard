class DashboardController < ApplicationController
  before_filter :find_by, only: [:index]
  def index
  	@title = "Last Reports"
    @reports = by_date(10)
    @branches = find_by(:branch)
    @platforms = find_by(:platform)
    @suites = find_by(:suite)
    @servers = find_by(:server)
    @total_count = Report.all.count
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

  def by_date(limit=5)
    reports = Report.order("date DESC")
    reports.first(limit)
  end

end
