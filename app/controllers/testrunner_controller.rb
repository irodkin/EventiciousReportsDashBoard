class TestrunnerController < ApplicationController
	def index
		@tests = ["session", "speaker", "attendees", "map", "indoor", "smoke_networking", "navi"]
	end
	def tests
		case params[:suite]
			when "Smoke"
				tests = ["session", "speaker", "attendees", "map", "indoor", "smoke_networking", "navi"]
			when "BigSmoke"
				tests = ["update_schedule", "update_speaker", "update_attendee", "now", "rate", "ask_schedule", "news", "update_indoor"]
			when "Networking"
				tests = ["hands", "ask", "profile", "exitPoints"]
			when "Meetings"
				tests = []
		end

		render partial: 'shared/tests', locals: {tests: tests}
	end
end
