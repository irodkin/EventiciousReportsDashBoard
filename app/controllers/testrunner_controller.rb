class TestrunnerController < ApplicationController
	def index
		@tests = ["smoke", "networking_smoke", "navigation", "speaker", "session", "attendees", "map", "indoor", "webview", "gallery"]
		@jobs = Job.all
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
		end

		render partial: 'shared/tests', locals: {tests: tests}
	end
end
