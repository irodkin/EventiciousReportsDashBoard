class DashboardController < ApplicationController
  def index
    @last_reports = self.by_date(5)
    @branches = self.by_branch
    @platforms = self.by_platform
    @suites = self.by_suite
  end
  def by_branch
    Report.group(:branch).count
  end
  def by_platform
    Report.group(:platform).count
  end
  def by_suite
    Report.group(:suite).count
  end
  def by_date(limit=5)
    reports = Report.order("date DESC")
    reports.last(limit)
  end
end
