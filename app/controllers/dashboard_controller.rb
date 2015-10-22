class DashboardController < ApplicationController
  def index
    @last_reports = self.by_date(10)
    @branches = self.by_branch
    @platforms = self.by_platform
    @suites = self.by_suite
    @servers = self.by_server
    @total_count = Report.all.count
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
  def by_server
    Report.group(:server).count
  end
  def by_date(limit=5)
    reports = Report.order("date DESC")
    reports.first(limit)
  end
end
