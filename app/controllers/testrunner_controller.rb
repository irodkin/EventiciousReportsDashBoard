class TestrunnerController < ApplicationController
	def index
		@tests = ["networking_smoke", "navigation", "speaker", "session", "attendees", "map", "indoor", "webview", "gallery"]
		@jobs = Job.all
		@suite = Suite.all
	end
	def tests
		case params[:suite]
			when "Smoke"
				tests = ["networking_smoke", "navigation", "speaker", "session", "attendees", "map", "indoor", "webview", "gallery"]
			when "BigSmoke"
				tests = ["update_sidebar","update_schedule","schedule_document", "now", "now_dt_valid", "rate_dt_valid", "schedule_ask_dt_valid", "ask_like", "rate", "schedule_ask", "filler", "coffebreak", "update_speaker", "update_attendees", "search_attendees", "news", "update_gallery", "update_indoor", "docs"]
			when "Networking"
				tests = ["hands", "ask", "profile", "exitPoints"]
			when "Meetings"
				tests = ["directmeeting", "canceledmeeting", "cancelmeeting", "cancelmeetinginvited"]
		end

		render partial: 'shared/tests', locals: {tests: tests}
	end
end
