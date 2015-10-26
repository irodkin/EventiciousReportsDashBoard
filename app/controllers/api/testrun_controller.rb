class Api::TestrunController < ApplicationController
	def index
		render text: params.to_json
	end
	def run
		render json: params.to_json
	end
end
