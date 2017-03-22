
$(document).on "click", ".delete_scenario", ()->
	id = $(this).attr("id")
	parent_div = $(this).parents("div")[0]
	$.ajax
		url: 'api/scenarioparser/delete_scenario'
		type: 'DELETE'
		dataType: 'json'
		data: id: id
		success: ()->
			$(parent_div).fadeOut(200)

$(document).on "click", "#parse", ()->
	suite = $('.parse_area').val()
	feature = $('.feature.active').text()
	$.ajax
		url: 'api/scenarioparser/parse'
		type: 'POST'
		dataType: 'html'
		data:
			suite: suite
			feature: feature
		success: (response)->
			$('.tests_container').html(response)
