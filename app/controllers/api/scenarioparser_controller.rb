require 'gherkin3/parser'

class Api::ScenarioparserController < ApplicationController

	def get_tests
		render json: {suite: Test.where(suite: params[:suite]).all},
		       status: 200
	end

	def get_test
		tests = Test.all
		needed = tests.find {|t| t[:tags].to_s.split(",").include?(params[:tag])}
		render json: {tests: needed},
		       status: 200
	end

	def add_feature
		s = Suite.new(title: params[:title], tag: params[:tag])
		if s.save
			suites = Suite.all
			render partial: 'shared/featurelist', locals: {suites: suites}
		else
			render json: {suk: "error"}
		end
	end

	def get_features
		Suite.all
	end

	def delete_feature
		feature = Suite.find(params[:id])
		scenarios_id = Test.where(suite: feature.title).all.collect {|st| st.id}
		if feature.destroy
			Test.where(suite: feature.title).find_each {|s| s.destroy}
			render json: {feature: feature.title,
			              scenarios: scenarios_id,
			              deleted: true},
			       status: 200
		else
			render json: {deleted: false},
			       status: 500
		end
	end

	def delete_scenario
		scenario = Test.find(params[:id])
		if scenario.destroy
			render json: {deleted: true},
			       status: 200
		else
			render json: {deleted: false},
			       status: 500
		end
	end

	def parse
		parser = Gherkin3::Parser.new
		parsed_feature = parser.parse(params[:suite])
		tags = parsed_feature[:tags].each {|t| t[:name]}
		feauture_name = parsed_feature[:name]
		scenarios = parsed_feature[:scenarioDefinitions]
		scenario = []
		scenarios.collect! {|s|
			scenario.push({suite: feauture_name,
			               tags: s[:tags].collect {|t| t[:name].delete!('@') }.join(","),
			               title: s[:name],
			               steps: s[:steps].collect {|st| "<div><span class=\"keyword\">#{st[:keyword]}</span> #{st[:text]}</div>"}.join("")})
		}
		scenario.each do |s|
			t = Test.new(s)
			t.save
		end
		scenarios = Test.where(suite: params[:feature])
		render partial: 'shared/scenarios',
		       locals: {scenarios: scenarios, edit: false}
	end
end
