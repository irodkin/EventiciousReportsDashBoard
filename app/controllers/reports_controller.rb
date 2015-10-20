class ReportsController < ApplicationController
  def index
    @reports = Report.all
    if params[:branch]
      @reports = Report.where(branch: params[:branch]).all
    end
    @branches = Report.group(:branch)
    @branch_count = Report.group(:branch).count
  end
  def show
    @reports = Report.where(id: params[:id]).first
  end
end
