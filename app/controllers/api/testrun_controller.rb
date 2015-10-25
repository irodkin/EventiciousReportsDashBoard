class Api::TestrunController < ApplicationController
	def index
		render text: params.to_json
	end
	def run
		render text: "Okay!"
	end
end
