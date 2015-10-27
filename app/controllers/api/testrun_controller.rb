class Api::TestrunController < ApplicationController
	def index
		render text: params.to_json
	end
	def run
		sleep 3
		render json: {
				:server => params[:server],
				:platform => params[:platform],
				:device => params[:device],
				:branch => params[:branch],
				:suite => params[:suite],
				:tests => params[:tests].join(","),
		}
	end
end
