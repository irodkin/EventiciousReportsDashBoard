class ReportsController < ApplicationController
  def index
    key = params.first[0]
    value =  params.first[1]
    @title = "By #{key.capitalize} #{value.capitalize}"
    @reports = Report.where(key.to_sym => value).order("date DESC").all
  end
end
