class ReportsController < ApplicationController
  def index
    if params[:branch]
      @reports = Report.where(branch: params[:branch]).all
    elsif params[:suite]
      @reports = Report.where(suite: params[:suite]).all
    elsif params[:platform]
      @reports = Report.where(platform: params[:platform]).all
    end
  end
end
