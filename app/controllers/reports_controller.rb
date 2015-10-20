class ReportsController < ApplicationController
  def index
    if params[:branch]
      @title = "By Branches"
      @reports = Report.where(branch: params[:branch]).order("date DESC").all
    elsif params[:suite]
      @title = "By Suites"
      @reports = Report.where(suite: params[:suite]).order("date DESC").all
    elsif params[:platform]
      @title = "By Platforms"
      @reports = Report.where(platform: params[:platform]).order("date DESC").all
    end
  end
end
