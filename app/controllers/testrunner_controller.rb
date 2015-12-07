class TestrunnerController < ApplicationController
	def index
		@tests = ["smoke", "networking_smoke", "navigation", "speaker", "session", "attendees", "map", "indoor", "webview", "gallery"]
		@jobs = Job.all
		@feature = Suite.all
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
		case params[:suite]
			when "Smoke"
				tests = ["smoke", "networking_smoke", "navigation", "speaker", "session", "attendees", "map", "indoor", "webview", "gallery"]
			when "BigSmoke"
				tests = ["bigsmoke", "update_sidebar","update_schedule", "schedule_document", "now", "now_dt_valid", "rate_dt_valid", "schedule_ask_dt_valid", "ask_like", "rate", "schedule_ask", "filler", "coffebreak", "update_speaker", "update_attendees", "search_attendees", "news", "update_gallery", "update_indoor", "docs"]
			when "Networking"
				tests = ["networking", "hands", "ask", "profile", "exitPoints", "logout", "meeting", "meeting_speaker"]
			when "Meetings"
				tests = ["meeting", "directmeeting", "canceledmeeting", "cancelmeeting", "cancelmeetinginvited"]
			when "MultiBigSmoke"
        tests = ["multievent", "multi_update_sidebar", "multi_update_schedule", "multi_schedule_document", "multi_now", "multi_now_dt_valid", "multi_rate_dt_valid", "multi_schedule_ask_dt_valid", "multi_ask_like", "multi_rate", "multi_schedule_ask", "multi_filler", "multi_coffebreak", "multi_update_speaker", "multi_update_attendees", "multi_search_attendees", "multi_news", "multi_update_gallery", "multi_update_indoor", "multi_docs"]
		end

		render partial: 'shared/tests', locals: {tests: tests}
	end
end
