class TestrunnerController < ApplicationController
	def index
		@tests = ["session", "speaker", "attendees", "map", "indoor", "smoke_networking", "navi"]
	end
	def tests
		case params[:suite]
			when "Smoke"
				tests = ["networking_smoke", "navigation", "speaker", "session", "attendees", "map", "indoor", "webview", "gallery"]
			when "BigSmoke"
				tests = ["update_schedule", "schedule_documents", "now", "rate", "schedule_ask", "filler", "coffebreak", "update_speaker", "update_attendees", "search_attendees", "news", "update_gallery", "update_indoor", "docs"]
			when "Networking"
				tests = ["hands", "ask", "profile", "exitPoints"]
			when "Meetings"
				tests = ["directmeeting", "canceledmeeting", "cancelmeeting", "cancelmeetinginvited"]
		end

		render partial: 'shared/tests', locals: {tests: tests}
	end
end
