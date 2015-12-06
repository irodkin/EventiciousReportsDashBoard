require 'gherkin3/parser'

class Api::ScenarioparserController < ApplicationController

  def get_tests
    render json: {
      :suite => Test.where(suite: params[:suite]).all
    },
      status: 200
  end

  def get_test
  	tests = Test.all
  	needed = tests.find {|t| (t[:tags].to_s.split(",")).include?(params[:tag])}
    render json: {
      :tests => needed
    },
      status: 200
  end

  def parse
    parser = Gherkin3::Parser.new
    parsed_feature = parser.parse(params[:suite])
    tags = parsed_feature[:tags].each { |t| t[:name] }
    feauture_name = parsed_feature[:name]
    scenarios = parsed_feature[:scenarioDefinitions]
    scenario = []
    scenarios.collect!  do |s|
    	scenario.push(
    	 :suite => feauture_name,	
         :tags =>(s[:tags].collect! { |t| t[:name].delete!('@') }).join(","),	
    	 :title =>"<div><b>#{s[:keyword]}:</b> #{s[:name]}</div>",
    	 :steps => (s[:steps].collect! { |st| "<div><b>#{st[:keyword]}</b> #{st[:text]}</div>"}).join(";")
         )
      end
    scenario.each do |s|
      t = Test.new(s)
      t.save
    end  
    render json: {
      :suite => Test.last
    },
      status: 200
  end
end
