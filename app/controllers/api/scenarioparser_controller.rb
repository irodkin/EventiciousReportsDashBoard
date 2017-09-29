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
		scenarios_id = Test.where(suite: feature.title).all.collect {|scenario| scenario.id}
		if feature.destroy
			Test.where(suite: feature.title).find_each {|scenario| scenario.destroy}
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
		parsed_feature = Gherkin3::Parser.new.parse(params[:suite])
		#feature_tags = parsed_feature[:tags].collect {|feature_tag| feature_tag[:name]}
		feauture_name = parsed_feature[:name]
		scenarios = parsed_feature[:scenarioDefinitions].collect {|scenario|
			tags = scenario[:tags].collect {|tag| tag[:name].delete('@')}.join(",")
			steps = scenario[:steps].collect {|step| "<div><span class=\"keyword\">#{step[:keyword]}</span> #{step[:text]}</div>"}.join("")
			{suite: feauture_name,
			 tags: tags,
			 title: scenario[:name],
			 steps: steps}
		}
		scenarios.each {|scenario| Test.new(scenario).save}
		scenarios = Test.where(suite: params[:feature])
		render partial: 'shared/scenarios',
		       locals: {scenarios: scenarios, edit: false}
	end
end
