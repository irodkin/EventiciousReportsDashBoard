class ReportsController < ApplicationController
  def index
    if params[:branch]
      @title = "By Branch #{params[:branch]}"
      @reports = Report.where(branch: params[:branch]).order("date DESC").all
    elsif params[:suite]
      @title = "By Suite #{params[:suite]}"
      @reports = Report.where(suite: params[:suite]).order("date DESC").all
    elsif params[:platform]
      @title = "By Platform #{params[:platform]}"
      @reports = Report.where(platform: params[:platform]).order("date DESC").all
    elsif params[:server]
      @title = "By Server #{params[:server]}"
      @reports = Report.where(server: params[:server]).order("date DESC").all
    end
  end
end
