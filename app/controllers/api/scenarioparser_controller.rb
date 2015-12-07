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

  def add_feature
    s = Suite.new(:title=>params[:title], :tag=>params[:tag])
    s.save

    render json: {
      :result => s
    },
    status: 200
  end

  def get_features
    Suite.all
  end

  def delete_feature
    feature = Suite.find(params[:id])
    if feature.destroy
      render json: { :deleted=>true },
             status: 200
    else
      render json: { :deleted=>false },
             status: 500
    end
  end

  def delete_scenario
    scenario = Test.find(params[:id])
    if scenario.destroy
      render json: { :deleted=>true },
             status: 200
    else
      render json: { :deleted=>false },
             status: 500
    end
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
    	 :title =>"<span class=\"keyword\">#{s[:keyword]}:</span> <span class=\"scenario_title\">#{s[:name]}<span>",
    	 :steps => (s[:steps].collect! { |st| "<div><span class=\"keyword\">#{st[:keyword]}</span> #{st[:text]}</div>"}).join("")
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
