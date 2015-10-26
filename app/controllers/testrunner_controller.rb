class TestrunnerController < ApplicationController
	def index
		@tests = ["321"]
	end
	def tests
		@tests = ["123"]
	end
end
