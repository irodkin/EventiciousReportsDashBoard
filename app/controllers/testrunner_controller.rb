class TestrunnerController < ApplicationController
	def index
		@tests = ["smoke", "networking_smoke", "navigation", "speaker", "session", "attendees", "map", "indoor", "webview", "gallery"]
		@jobs = Job.all
		@feature = Suite.all
		@head_tag = Suite.first.tag
	end
	def get_scenario_of_feature
		scenarios = Test.where(suite: params[:suite]).all

		render partial: 'shared/scenarios', locals: {scenarios: scenarios}
	end
	def add_feature
		suites = Suite.all
		render partial: 'shared/addfeature', locals: {suites: suites}
	end
	def tests
		tests = Test.where(suite: params[:suite]).all
		tags_arr = tests.collect { |t| t.tags}
		split = []
		to_delete = []
		tags_arr.collect! do |t|
			if t.split(",").size>1
				t.split(",").each {|t| split.push t }
				to_delete.push t
			end
			t
		end
		to_delete.each {|d| tags_arr.delete d}
		split.each {|s| tags_arr.push s}
		scenarios = []
		tags_arr.uniq!
		tags_arr.each do |t|
			scenarios_a = tests.find_all { |f| f.tags.split(",").include?(t)}
			scenarios_b = []
			scenarios_a.each do |s|
				scenarios_b.push "<div>#{s.title}</div><div style=\"margin-left: 5px\">#{s.steps}</div>"
			end
			scenarios.push([scenarios_b, t])
		end
		head_tag = Suite.where(title: params[:suite]).first.tag
		render partial: 'shared/tests', locals: {tests: scenarios, head_tag: head_tag}
	end
end
