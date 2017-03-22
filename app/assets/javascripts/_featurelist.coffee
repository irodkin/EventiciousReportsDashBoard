
$(document).on "click", ".feature", ()->
	$('.feature.active').removeClass('active')
	$(this).addClass('active')
	suite = $(this).text()
	$.ajax
		url: 'testrunner/get_scenario_of_feature'
		type: 'GET'
		dataType: 'html'
		data: suite: suite
		success: (response)->
			$('.tests_container').html(response)

$(document).on "click", ".delete_feature", ()->
	id = $(this).attr("id")
	parent_div = $(this).parents("div")[2]
	$.ajax
		url: 'api/scenarioparser/delete_feature'
		type: 'DELETE'
		dataType: 'json'
		data: id: id
		success: ()->
			$(parent_div).fadeOut(200)

$(document).on "click", ".add_scenarios", ()->
	$.ajax
		url: 'testrunner/get_scenario_of_feature'
		type: 'GET'
		dataType: 'html'
		data:
			suite: $(this).attr("id")
			edit: true
		success: (response)->
			$('.tests_container').html(response)
